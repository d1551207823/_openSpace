// 实践 POW， 编写程序（编程语言不限）用自己的昵称 + nonce，不断修改nonce 进行 sha256 Hash 运算：
// 直到满足 4 个 0 开头的哈希值，打印出花费的时间、Hash 的内容及Hash值。
// 再次运算直到满足 5 个 0 开头的哈希值，打印出花费的时间、Hash 的内容及Hash值。

// 题目#2
// 实践非对称加密 RSA（编程语言不限）：使用crypto
// 先生成一个公私钥对
// 用私钥对符合 POW 4 个 0 开头的哈希值的 “昵称 + nonce” 进行私钥签名
// 用公钥验证
const crypto = require('crypto');
const {publicKey, privateKey} = crypto.generateKeyPairSync('rsa', {
    modulusLength: 1024,
    publicKeyEncoding: {
        type: 'spki',
        format: 'pem'
    },
    privateKeyEncoding: {
        type: 'pkcs8',
        format: 'pem'
    }
})
const getHash = (str) => {
    return crypto.createHash('sha256').update(hash).digest('hex');
}
const sign = (str) => {
    return crypto.sign('sha256', Buffer.from(str), {
        key: privateKey,
        padding: crypto.constants.RSA_PKCS1_PSS_PADDING
    }).toString('base64')
}
const verify = (str, sign) => {
    return crypto.verify('sha256', Buffer.from(str), {
        key: publicKey,
        padding: crypto.constants.RSA_PKCS1_PSS_PADDING
    }, Buffer.from(sign, 'base64'))
}


const main = () => {
    const authors = '邓政坚'
    let nonce = 0;
    let start = new Date().getTime();
    let hash = '';
    let hashValue = '';
    let zero = '00000';
    let zero1 = '0000';
    let zeroResult = false
    let zeroResult1 = false
    while (true) {
        hashValue = authors + nonce;
        hash = getHash(hashValue);
        if (hash.startsWith(zero1) && !zeroResult) {
            console.log('Zero:0000 => 花费时间：', (new Date().getTime() - start).toString() + 'ms');
            console.log('Hash的内容：', hashValue);
            console.log('Hash值：', hash);
            zeroResult = true
            // 签名
            const signValue = sign(hashValue)
            console.log('签名：', signValue)
            // 验证
            const verifyResult = verify(hashValue, signValue)
            console.log('验证：', verifyResult)
        }
        if (hashValue.startsWith(zero)) {
            console.log('Zero:00000 =>花费时间：', (new Date().getTime() - start).toString() + 'ms');
            console.log('Hash的内容：', hash);
            console.log('Hash值：', hashValue);
            zeroResult1 = true
        }
        nonce++;
        if (zeroResult && zeroResult1) {
            break;
        }
    }
}
main()

