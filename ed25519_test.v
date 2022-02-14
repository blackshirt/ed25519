module ed25519

import encoding.hex
import log
import os
import crypto.hmac

/*
struct ZeroReader {}

fn (z ZeroReader) read(mut buf []byte) ?int {
	for i, _ in buf {
		buf[i] = 0
	}
	return buf.len
}
*/
fn test_sign_verify() ? {
	// mut zero := ZeroReader{}
	public, private := generate_key() ?

	message := 'test message'.bytes()
	sig := sign(private, message) ?
	res := verify(public, message, sig) or { false }
	assert res == true
	

	wrongmessage := 'wrong message'.bytes()
	res2 := verify(public, wrongmessage, sig) ?
	assert res2 == false
	
}

fn test_equal() ? {
	public, private := generate_key() ?

	assert public.equal(public) == true
	
	// This is not AVAILABLE
	/*
	if !public.Equal(crypto.Signer(private).Public()) {
		t.Errorf("private.Public() is not Equal to public: %q", public)
	}*/
	assert private.equal(private) == true

	otherpub, otherpriv := generate_key() ?
	assert public.equal(otherpub) == false

	assert private.equal(otherpriv) == false
}

fn test_malleability() ? {
	// https://tools.ietf.org/html/rfc8032#section-5.1.7 adds an additional test
	// that s be in [0, order). This prevents someone from adding a multiple of
	// order to s and obtaining a second valid signature for the same message.
	msg := [byte(0x54), 0x65, 0x73, 0x74]
	sig := [byte(0x7c), 0x38, 0xe0, 0x26, 0xf2, 0x9e, 0x14, 0xaa, 0xbd, 0x05, 0x9a, 0x0f, 0x2d,
		0xb8, 0xb0, 0xcd, 0x78, 0x30, 0x40, 0x60, 0x9a, 0x8b, 0xe6, 0x84, 0xdb, 0x12, 0xf8, 0x2a,
		0x27, 0x77, 0x4a, 0xb0, 0x67, 0x65, 0x4b, 0xce, 0x38, 0x32, 0xc2, 0xd7, 0x6f, 0x8f, 0x6f,
		0x5d, 0xaf, 0xc0, 0x8d, 0x93, 0x39, 0xd4, 0xee, 0xf6, 0x76, 0x57, 0x33, 0x36, 0xa5, 0xc5,
		0x1e, 0xb6, 0xf9, 0x46, 0xb3, 0x1d]
	publickey := [byte(0x7d), 0x4d, 0x0e, 0x7f, 0x61, 0x53, 0xa6, 0x9b, 0x62, 0x42, 0xb5, 0x22,
		0xab, 0xbe, 0xe6, 0x85, 0xfd, 0xa4, 0x42, 0x0f, 0x88, 0x34, 0xb1, 0x08, 0xc3, 0xbd, 0xae,
		0x36, 0x9e, 0xf5, 0x49, 0xfa]
	// verify should fail on provided bytes
	res := verify(publickey, msg, sig) or { false }
	assert res == false

	
}

fn test_sign_input_from_djb_ed25519_crypto_sign_input() ? {
	contents := os.read_lines('testdata/sign.input') or { panic(err.msg) } //[]string
	mut lg := log.Log{}
	for i, item in contents {
		parts := item.split(':') // []string
		// println(parts)
		if parts.len != 5 {
			lg.fatal('not contains len 5')
		}
		assert parts.len == 5
		privbytes := hex.decode(parts[0]) ?
		pubkey := hex.decode(parts[1]) ?
		msg := hex.decode(parts[2]) ?
		mut sig := hex.decode(parts[3]) ?
		assert pubkey.len == public_key_size

		sig = sig[..signature_size]
		mut priv := []byte{len: private_key_size, cap: private_key_size}
		copy(priv[..], privbytes)
		copy(priv[32..], pubkey)

		sig2 := sign(priv[..], msg) ?
		assert hmac.equal(sig, sig2[..])
		

		res := verify(pubkey, msg, sig2) ?
		assert res == true
		

		priv2 := new_key_from_seed(priv[..32])
		assert hmac.equal(priv[..], priv2)
		
		pubkey2 := priv2.public_key()
		assert hmac.equal(pubkey, pubkey2)
		
		seed2 := priv2.seed()
		assert hmac.equal(priv[0..32], seed2) == true

		/*
		if seed := priv2.Seed(); !bytes.Equal(priv[:32], seed) {
			t.Errorf("recreating key pair gave different seed on line %d: %x vs %x", lineNo, priv[:32], seed)
		}*/
	}
}
