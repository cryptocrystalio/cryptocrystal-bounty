pragma solidity ^0.4.21;

import './zeppelin-solidity/contracts/math/SafeMath.sol';
import './zeppelin-solidity/contracts/ownership/Ownable.sol';
import './zeppelin-solidity/contracts/token/ERC20/MintableToken.sol';
import './zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol';

// @title Acceptable
// @dev Provide basic access control.
//      Sender is supposed to be CryptoCrystal contract address in our contracts.
contract Acceptable is Ownable {
    address sender;

    modifier onlyAcceptable {
        require(msg.sender == sender);
        _;
    }

    function setAcceptable(address _sender) public onlyOwner {
        sender = _sender;
    }
}

// @title Sellable
// @dev Sell tokens.
//      Token is supposed to be Pickaxe contract in our contracts.
//      Actual transferring tokens operation is to be implemented in inherited contract.
contract Sellable is Ownable {
    using SafeMath for uint256;

    address public wallet;
    uint256 public rate;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    function Sellable(address _wallet) public {
        rate = 200;
        wallet = _wallet;
    }

    function () external payable {
        buyPickaxes(msg.sender);
    }

    function buyPickaxes(address _beneficiary) public payable {
        uint256 _weiAmount = msg.value;
        uint256 _tokens = _weiAmount.mul(rate).div(1 ether);
        _transferFromOwner(msg.sender, _tokens);
        _forwardFunds();
    }

    function _transferFromOwner(address _to, uint256 _value) internal {
        // *MUST* be overwritten
        require(false);
    }

    function _forwardFunds() internal {
        wallet.transfer(msg.value);
    }
}

// @title Minable
// @dev calculate mining crystal amounts and weights
//
contract Minable is Ownable {
    using SafeMath for uint256;

    // Total weight of crystals not mined yet
    // 21 * 10^13 mg
    uint256 public totalWeight = 210 * 1000 * 1000 * 1000 * 1000;

    // Total weight of mined crystals
    uint256 public currentWeight = 0;

    // block generation time
    uint256 public secondsPerBlock = 12;

    // 365 days * 24 hours * 60 minutes * 60 seconds
    uint256 public secondsPerYear = 365 * 24 * 60 * 60;

    // 24 hours * 60 minutes * 60 minutes
    uint256 public secondsPerDay = 24 * 60 * 60;

    uint256 public initialBlock = block.number;

    uint256 public nextUpdateBlock = initialBlock;

    uint256 public estimatedWeight;

    function Minable() public {
        estimatedWeight = _getWeight(initialBlock);
    }

    // @dev We will set new block generation time if it changes
    function setSecondsPerBlock(uint256 _secs) external onlyOwner {
        require(_secs > 0);
        secondsPerBlock = _secs;
    }

    // @dev Number of blocks per day is 60 * 60 * 24 / secondsPerBlock.
    function _getBlocksPerDay() public view returns(uint256) {
        uint256 secondsPerDay = 86400;
        return secondsPerDay.div(secondsPerBlock);
    }

    // @dev Number of blocks per year is 60 * 60 * 24 * 365 * secondsPerBlock.
    function _getBlocksPerYear() public view returns(uint256) {
        return secondsPerBlock.mul(31536000);
    }

    // @dev Map block number to block index.
    //      First block is number 0.
    function _getBlockIndex(uint256 _blockNumber) public view returns(uint256) {
        return _blockNumber.sub(initialBlock);
    }

    // @dev Map block number to year index.
    //      First (blocksPerYear - 1) blocks are number 0.
    function _getYearIndex(uint256 _blockNumber) public view returns(uint256) {
        uint256 _blockIndex =  _getBlockIndex(_blockNumber);
        uint256 _blocksPerYear = _getBlocksPerYear();
        return _blockIndex.div(_blocksPerYear);
    }

    // @dev
    function _getWaitingBlocks() public view returns(uint256) {
        return secondsPerDay.div(secondsPerBlock);
    }

    // @dev getRandom is now "EXTREMELY" native implementation.
    //      We need more proper one!
    // @param _max max value to be generated
    // @param _seed random seed
    function _getRandom(uint256 _max, uint256 _seed) internal view returns(uint256) {
        bytes32 hash = keccak256(block.timestamp + _seed);
        return (uint256(hash) % _max) + 1;
    }


    // @dev calculate sum of array
    // @param array
    function sum(uint256[] array) public pure returns(uint256) {
        uint256 _sum = 0;
        for(uint256 i = 0; i < array.length; i++) {
            _sum = _sum.add(array[i]);
        }
        return _sum;
    }

    // @dev sampling weighted index with replacement
    function _getWeightedIndexWithRestore(uint256[] _weights, uint256 _seed) internal view returns(uint256) {
        uint256 _totalWeight = sum(_weights);
        uint256 _random = _getRandom(_totalWeight, _seed);
        uint256 _cumsum = 0;
        for(uint256 i = 0; i < _weights.length; i++) {
            _cumsum = _cumsum.add(_weights[i]);
            if(_random > _cumsum) {
                return i;
            }
        }
        return _weights.length - 1;
    }


    // @dev get crystal kinds randomly
    // @param _weights
    // @param _length length of random kinds to generate
    // @param _initialSeed
    function _getRandomKinds(uint256[] _weights, uint256 _length, uint256 _initialSeed) public view returns(
        uint256[] _kinds,
        uint256 _seed
    ) {
        _seed = _initialSeed;
        _kinds = new uint256[](_length);
        for(uint256 i = 0; i < _length; i++) {
            _kinds[i] = _getWeightedIndexWithRestore(_weights, _seed);
            _seed++;

            require(_kinds[i] < 100);
        }
    }

    // @dev get crystal weights randomly
    // @param _length length of random weights to generate
    // @param _estimatedWeight
    // @param _initialSeed
    function _getRandomWeights(uint256 _length, uint256 _estimatedWeight, uint256 _initialSeed) public view returns(
        uint256[] _weights,
        uint256 _seed
    ) {
        _seed = _initialSeed;
        _weights = new uint256[](_length);

        uint256 _sum = 0;
        for(uint256 i = 0; i < _length; i++) {
            _weights[i] = _getRandom(100, _seed);
            _seed++;
            _sum = _sum.add(_weights[i]);
        }

        for(i = 0; i < _length; i++) {
            _weights[i] = _weights[i].mul(_estimatedWeight);
            _weights[i] = _weights[i].div(_sum);

            require(_weights[i] > 0);
        }
    }

    // @dev decide crystal kinds and weights.
    //      kinds and weights are decided independently.
    // @param _weights
    function _decideCrystals(uint256[] _weights, uint256 _initialSeed) public view returns(
        uint256[] _kinds,
        uint256[] _minedWeights,
        uint256 _seed
    ) {
        _seed = _initialSeed;
        uint256 _crystalAmount = _getRandom(10, _seed);
        _seed++;
        (_kinds, _seed) = _getRandomKinds(_weights, _crystalAmount, _seed);
        (_minedWeights, _seed) = _getRandomWeights(_crystalAmount, estimatedWeight, _seed);
    }

    // @dev
    //
    function _estimatedSupply(uint256 _blockNumber) public view returns(uint256) {
        uint256 _sum = 0;
        uint256 _yearIndex = _getYearIndex(_blockNumber); // 0-based
        for(uint256 i = 0; i < _yearIndex; i++) {
            _sum = _sum.add(totalWeight * (2 ** _yearIndex));
        }
        uint256 _blockIndex = _getBlockIndex(_blockNumber) + 1; // 1-based
        uint256 _yearFactor = 2 ** (_yearIndex + 1);
        uint256 weightOfThisYear = totalWeight * secondsPerBlock * _blockIndex / (_yearFactor * secondsPerYear);
        _sum = _sum.add(weightOfThisYear);
        return _sum;
    }

    // @dev get total weight of crystals to be mined.
    //      Sum of weights of mined crystals is this value.
    function _getWeight(uint256 _blockNumber) public view returns(uint256) {
        uint256 _supply = _estimatedSupply(_blockNumber);
        uint256 _yearFactor = 2 ** (_getYearIndex(_blockNumber));
        uint256 _controlValve;

        if(currentWeight > _supply) {
            // When current weight exceeds estimated supply, multiply control factor below.
            _controlValve = _supply / currentWeight;
        } else {
            _controlValve = 1;
        }

        return _controlValve * 100000 / _yearFactor;
    }

    // @dev update currentWeight and estimatedWeight
    function _updateMiningBase(uint256 _weight) internal {
        require(_weight > 0);

        currentWeight = currentWeight.add(_weight);

        if(block.number >= nextUpdateBlock) {
            estimatedWeight = _getWeight(now);
            nextUpdateBlock = block.number + _getBlocksPerDay();
        }
    }
}

// @title Exchangeable
// @dev validate exchange condition
contract Exchangeable {
    function _validatedExchangeInfo(
        CrystalBase crystal,
        ExchangeBase exchange,
        address _exchanger,
        uint256 _exchangeId,
        uint256 _tokenId
    ) internal view returns(
        address _exOwner,
        uint256 _exTokenId
    ) {
        uint256 _;
        uint256 _crystalKind;
        uint256 _crystalWeight;
        (_, _crystalKind, _crystalWeight) = crystal.getCrystal(_tokenId);

        uint256 _exKind;
        uint256 _exWeight;
        uint64 _exCreatedAt;
        (_exOwner, _exTokenId, _exKind, _exWeight, _exCreatedAt) = exchange.getExchange(_exchangeId);

        require(_exCreatedAt > 0); // exchange exists
        require(_exOwner != _exchanger); // exchange is not my own
        require(crystal.ownerOf(_tokenId) == _exchanger); // exchanger has the crystal of tokenId
        require(_crystalKind == _exKind); // kind is the same
        require(_crystalWeight >= _exWeight); // weight is larger than or equal to
    }
}


// @title CryptoCrystal
// @dev Almost all application specific logic is in this contract.
//      CryptoCrystal acts as a facade to Pixaxe(ERC20), CrystalBase(ERC721), ExchangeBase as to transactions.
contract CryptoCrystal is Sellable, Minable, Exchangeable {
    Pickaxe pickaxe;
    CrystalBase crystal;
    ExchangeBase exchange;

    uint256[] crystalWeights = [
        500000000000,2268000000000,13125000000000,315000000000,
        2358300000000,1512000000000,6552000000000,8295000000000,
        71777343750,7623000000000,6846000000000,6762000000000,
        50372265625,307617187500,1025390625000,1025390625000,
        1025390625000,51269531250,315000000000,50400000000,
        205078125000,205078125000,102539062500,50244140625,
        63000000000,205078125000,1025390625000,1025390625000,
        1025390625000,1025390625000,1025390625000,76904296875,
        153808593750,693000000000,102539062500,5470500000000,
        153808593750,205078125000,153808593750,153808593750,
        205078125000,153808593750,76904296875,1538085937500,
        922851562500,1025390625000,717773437500,820312500000,
        2563476562500,13842773437500,8203125000000,7434082031250,
        4614257812500,5639648437500,5383300781250,3588867187500,
        2563476562500,3588867187500,1025390625000,3076171875000,
        2563476562500,512695312500,410156250000,3076171875000,
        3076171875000,20507812500,35888671875,25634765625,
        51269531250,3999023437500,6152343750000,5639648437500,
        4614257812500,3588867187500,7177734375000,410156250000,
        410156250000,20507812500,1025390625000,1025390625000,
        512695312500,1025390625000,307617187500,410156250000,
        1025390625000,1025390625000,1025390625000,2050781250000,
        2050781250000,5565000000000,6573000000000,410156250000,
        1025390625000,307617187500,1025390625000,205078125000,
        205078125000,205078125000,205078125000,820312500000
    ];

    event Mined(address indexed _owner, uint256 _crystalId, uint256 _kind, uint256 _weight, uint256 _gene);

    uint256 seed = 0;

    function CryptoCrystal(
        Pickaxe _pickaxe,
        CrystalBase _crystal,
        ExchangeBase _exchange,
        address _wallet
    ) Sellable(_wallet) public {
        pickaxe = _pickaxe;
        crystal = _crystal;
        exchange = _exchange;
    }

    // @dev mineCrystals consists of two basic operations that burn pickaxes and mint crystals.
    // @param _amount uint256 the amount of tokens to be burned
    function mineCrystals(uint256 _amount) external {
        require(pickaxe.balanceOf(msg.sender) >= _amount);
        require(_amount > 0);

        for(uint256 i = 0; i < _amount; i++) {
            uint256[] memory _kinds;
            uint256[] memory _weights;

            (_kinds, _weights, seed) = _decideCrystals(crystalWeights, seed);
            uint256 _minedWeight = 0;

            pickaxe.burn(msg.sender, _amount);
            for (uint256 j = 0; j < _kinds.length; j++) {
                _mine(msg.sender, _kinds[j], _weights[j]);
                _minedWeight = _minedWeight.add(_weights[j]);
            }
            _updateMiningBase(_minedWeight);
        }
    }

    // @dev meltCrystals consists of two basic operations.
    //      It burns old crystals and mint new crystal.
    //      The weight of new crystal is the same to total weight of bunred crystals.
    // @notice meltCrystals may have bugs. We will fix later.
    // @param uint256[] _tokenIds the token ids of crystals to be melt
    function meltCrystals(uint256[] _tokenIds) external {
        uint256 _length = _tokenIds.length;

        require(2 <= _length && _length <= 10);

        uint256 _;
        uint256[] memory _kinds = new uint256[](_length);
        uint256[] memory _weights = new uint256[](_length);

        for(uint256 i = 0; i < _length; i++) {
            require(crystal.ownerOf(_tokenIds[i]) == msg.sender);
            (_, _kinds[i], _weights[i]) = crystal.getCrystal(_tokenIds[i]);
            if (i != 0) {
                require(_kinds[i] == _kinds[i - 1]);
            }
        }

        uint256 _totalWeight = 0;
        for(i = 0; i < _length; i++) {
            _totalWeight = _totalWeight.add(_weights[i]);
            crystal.burn(msg.sender, _tokenIds[i]);
        }
        uint256 _gene = _generateGene();
        crystal.mint(msg.sender, _gene, _kinds[0], _totalWeight);
    }

    // @dev create exchange
    // @param uint256 _tokenId tokenId you want to exchange
    // @param uint256 _kind crystal kind you want to get
    // @param uint256 _weight minimum crystal weight you want to get
    function createExchange(uint256 _tokenId, uint256 _kind, uint256 _weight) external {
        address _owner = msg.sender;

        require(crystal.ownerOf(_tokenId) == _owner);
        require(!exchange.isOnExchange(_tokenId));
        require(_kind <= 100);

        crystal.transferFrom(_owner, exchange, _tokenId);
        uint256 _id = exchange.create(_owner, _tokenId, _kind, _weight, uint64(now));
    }


    // @dev cancel exchange
    // @param uint256 _id exchangeId you want to cancel
    function cancelExchange(uint256 _id) external {
        address _owner = msg.sender;
        uint256 _tokenId = exchange.getTokenId(_id);
        crystal.transferFrom(exchange, _owner, _tokenId);
        exchange.remove(_id);
    }

    // @dev bid exchange
    // @param uint256 _exchangeId exchange id you want to bid
    // @param uint256 _tokenId token id of your crystal to be exchanged
    function bidExchange(uint256 _exchangeId, uint256 _tokenId) external {
        address _from = msg.sender;
        address _exOwner;
        uint256 _exTokenId;
        (_exOwner, _exTokenId) = _validatedExchangeInfo(crystal, exchange, _from, _exchangeId, _tokenId);

        crystal.transferFrom(_from, _exOwner, _tokenId);
        crystal.transferFrom(exchange, _from, _exTokenId);
        exchange.succeed(_exchangeId, _tokenId);
    }

    function _transferFromOwner(address _to, uint256 _value) internal {
        pickaxe.transferFromOwner(_to, _value);
    }

    function _mine(address _owner, uint256 _kind, uint256 _weight) internal {
        uint256 _gene = _generateGene();
        uint256 _tokenId = crystal.mint(_owner, _gene, _kind, _weight);
        crystalWeights[_kind] = crystalWeights[_kind].sub(_weight);
        emit Mined(_owner, _tokenId, _kind, _weight, _gene);
    }

    function _generateGene() internal returns(uint256) {
        seed++;
        return seed;
    }
}

// @title Pickaxe
// @dev ERC20 token.
//      transferFromOwner and burn are supposed to be called from CryptoCrystal contract only.
contract Pickaxe is Acceptable, MintableToken {
    string public name = 'Pickaxe';
    string public symbol = 'PKX';
    uint8 public decimals = 0;
    uint256 public initialSupply = 20000000;

    function Pickaxe() public {
        mint(msg.sender, initialSupply);
    }

    event Burn(address indexed burner, uint256 value);

    function transferFromOwner(address _to, uint256 _amount) public onlyAcceptable {
        address _from = owner;
        balances[_from] = balances[_from].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(_from, _to, _amount);
    }

    function burn(address _from, uint256 _amount) public onlyAcceptable {
        balances[_from] = balances[_from].sub(_amount);
        totalSupply_ = totalSupply_.sub(_amount);
        emit Burn(_from, _amount);
        emit Transfer(_from, address(0), _amount);
    }
}


// @title CrystalBase
// @dev ERC721 token.
//      mint, burn and transferFrom are supposed to be called from CryptoCrystal contract only.
contract CrystalBase is Acceptable, ERC721Token {
    struct Crystal {
        uint256 tokenId;
        uint256 gene;
        uint256 kind;
        uint256 weight;
    }

    mapping(uint256 => Crystal) internal tokenIdToCrystal;
    event CrystalBurned(address indexed burner, uint256 tokenId);
    event CrystalMinted(address indexed burner, uint256 gene, uint256 kind, uint256 weight);

    function CrystalBase() ERC721Token("crystal", "CTL") public {

    }

    function mint(
        address _owner,
        uint256 _gene,
        uint256 _kind,
        uint256 _weight
    ) public onlyAcceptable returns(uint256) {
        require(_gene > 0);
        require(_weight > 0);

        uint256 _index = allTokens.length;
        uint256 _tokenId = _index + 1;
        super._mint(_owner, _tokenId);
        Crystal memory _crystal = Crystal({
            tokenId: _tokenId,
            gene: _gene,
            kind: _kind,
            weight: _weight
            });
        tokenIdToCrystal[_tokenId] = _crystal;
        emit CrystalMinted(_owner, _gene, _kind, _weight);
        return _tokenId;
    }

    function burn(address _owner, uint256 _tokenId) public onlyAcceptable {
        require(ownerOf(_tokenId) == owner);

        delete tokenIdToCrystal[_tokenId];
        super._burn(_owner, _tokenId);
        emit CrystalBurned(_owner, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public onlyAcceptable {
        require(ownerOf(_tokenId) == _from);
        require(_to != address(0));

        clearApproval(_from, _tokenId);
        removeTokenFrom(_from, _tokenId);
        addTokenTo(_to, _tokenId);

        emit Transfer(_from, _to, _tokenId);
    }

    function getCrystalsSummary(address _owner) external view returns(
        uint256[] amounts,
        uint256[] weights
    ) {
        amounts = new uint256[](100);
        weights = new uint256[](100);
        uint256 _tokenCount = ownedTokensCount[_owner];
        for (uint256 i = 0; i < _tokenCount; i++) {
            uint256 _tokenId = ownedTokens[_owner][i];
            Crystal memory _crystal = tokenIdToCrystal[_tokenId];
            amounts[_crystal.kind] = amounts[_crystal.kind].add(1);
            weights[_crystal.kind] = weights[_crystal.kind].add(_crystal.weight);
        }
    }

    function getCrystals(address _owner) external view returns(
        uint256[] tokenIds,
        uint256[] genes,
        uint256[] kinds,
        uint256[] weights
    ) {
        uint256 _tokenCount = ownedTokensCount[_owner];
        tokenIds = new uint256[](_tokenCount);
        genes = new uint256[](_tokenCount);
        kinds = new uint256[](_tokenCount);
        weights = new uint256[](_tokenCount);
        for (uint256 i = 0; i < _tokenCount; i++) {
            uint256 _tokenId = ownedTokens[_owner][i];
            Crystal memory _crystal = tokenIdToCrystal[_tokenId];
            tokenIds[i] = _tokenId;
            genes[i] = _crystal.gene;
            kinds[i] = _crystal.kind;
            weights[i] = _crystal.weight;
        }
    }

    function getCrystal(uint256 _tokenId) public view returns(
        uint256 gene,
        uint256 kind,
        uint256 weight
    ) {
        require(_tokenId != 0);

        Crystal memory _crystal = tokenIdToCrystal[_tokenId];
        gene = _crystal.gene;
        kind = _crystal.kind;
        weight = _crystal.weight;
    }
}

// @title ExchangeBase
// @dev create, remove and succeed are supposed to be called from CryptoCrystal contract only.
contract ExchangeBase is Acceptable {
    struct Exchange {
        address owner;
        uint256 tokenId;
        uint256 kind;
        uint256 weight;
        uint64 createdAt;
    }

    Exchange[] exchanges;

    mapping(uint256 => Exchange) tokenIdToExchange;

    event ExchangeCreated(uint256 indexed id, uint256 tokenId, uint256 kind, uint256 weight);
    event EchangeSuccessful(uint256 indexed id, uint256 tokenId, uint256 exchangerTokenId);
    event ExchangeRemoved(uint256 indexed id);

    function ExchangeBase() public {

    }

    function create(
        address _owner,
        uint256 _tokenId,
        uint256 _kind,
        uint256 _weight,
        uint64 _createdAt
    ) public onlyAcceptable returns(uint256) {
        require(!isOnExchange(_tokenId));
        require(_weight > 0);
        require(_createdAt > 0);

        Exchange memory _exchange = Exchange({
            owner: _owner,
            tokenId: _tokenId,
            kind: _kind,
            weight: _weight,
            createdAt: _createdAt
            });
        uint256 _id = exchanges.push(_exchange) - 1;
        tokenIdToExchange[_tokenId] = _exchange;
        emit ExchangeCreated(_id, _tokenId, _kind, _weight);
        return _id;
    }

    function remove(uint256 _id) public onlyAcceptable {
        require(isOnExchangeById(_id));

        Exchange memory _exchange = exchanges[_id];
        delete tokenIdToExchange[_exchange.tokenId];
        delete exchanges[_id];

        emit ExchangeRemoved(_id);
    }

    function succeed(uint256 _id, uint256 _tokenId) public onlyAcceptable {
        require(isOnExchangeById(_id));

        Exchange memory _exchange = exchanges[_id];
        delete tokenIdToExchange[_exchange.tokenId];
        delete exchanges[_id];

        emit ExchangeRemoved(_id);
        emit EchangeSuccessful(_id, _exchange.tokenId, _tokenId);
    }

    function getExchange(uint256 _id) public view returns(
        address owner,
        uint256 tokenId,
        uint256 kind,
        uint256 weight,
        uint64 createdAt
    ) {
        require(isOnExchangeById(_id));

        Exchange memory _exchange = exchanges[_id];
        owner = _exchange.owner;
        tokenId = _exchange.tokenId;
        kind = _exchange.kind;
        weight = _exchange.weight;
        createdAt = _exchange.createdAt;
    }

    function getTokenId(uint256 _id) public view returns(uint256) {
        require(isOnExchangeById(_id));

        Exchange memory _exchange = exchanges[_id];
        return _exchange.tokenId;
    }

    function isOnExchange(uint256 _tokenId) public view returns(bool) {
        return tokenIdToExchange[_tokenId].createdAt > 0;
    }

    function isOnExchangeById(uint256 _id) internal view returns(bool) {
        return exchanges[_id].createdAt > 0;
    }
}