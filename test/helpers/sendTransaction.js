export default function sendTransaction(instance, from, value) {
    return instance.sendTransaction({
        from: from,
        value: value
    });
}