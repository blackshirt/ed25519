module ed25519

// import io

interface Signer {
	// public_key returns the public key corresponding to the opaque,
	// private key.
	public_key() PublicKey
	// Sign signs digest with the private key, possibly using entropy from
	// rand. return signature bytes
	sign(digest []byte) ?[]byte
}

interface Decrypter {
	// Public returns the public key corresponding to the opaque,
	// private key.
	public_key() PublicKey
	// Decrypt decrypts msg. and return plaintext bytes
	decrypt(msg []byte) ?[]byte
}
