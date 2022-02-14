module main

import encoding.hex	
import encoding.base64
import ed25519


// adapted from https://asecuritysite.com/signatures/ed25519
fn main() {
	msg := "Hello Girl"

	publ, priv := ed25519.generate_key() or { panic(err.msg) }

	m := msg.bytes()

	sig := ed25519.sign(priv, m) or { panic(err.msg) }

	println("=== Message ===")
	println("Msg: $msg \nHash: $m")
	
	println("=== Public key ===")
	println("Public key (Hex): ${publ.bytestr()}")
	println("   Public key (Base64): ${base64.encode(publ)}")

	println("=== Private key ===")
	println("Private key: ${priv.seed()}") //priv[0:32]
	println("   Private key (Base64): ${base64.encode(priv.seed())}") //priv[0:32]
	println("   Private key (Base64) Full key:  ${base64.encode(priv)}")
	println("   Private key (Full key in Hex): ${hex.encode(priv)}")
	
	println("=== signature (R,s) ===")
	println("signature: R=${sig[0..32]} s=${sig[32..64]}")
	println("   signature (Base64)=${base64.encode(sig)}")

	rtn := ed25519.verify(publ, m, sig) or { panic(err.msg) }

	if rtn {
		println("signature verified :$rtn")
	} else {
		println("signature does not verify :${!rtn}")
	}
}
