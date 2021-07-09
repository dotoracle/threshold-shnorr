pragma solidity >=0.4.14;

import "./Curve.sol";

// https://eprint.iacr.org/2004/027.pdf
library UAOSRing
{
	using Curve for Curve.G1Point;
	function RingLink( Curve.G1Point memory Y, Curve.G1Point memory M, Curve.G1Point memory tagpoint, uint256 s, uint256 c )
		internal view
		returns (uint256)
	{
		Curve.G1Point memory a = Curve.g1add(Curve.g1mul(Curve.P1(), s), Curve.g1mul(Y, c));
		Curve.G1Point memory b = Curve.g1add(Curve.g1mul(M, s), Curve.g1mul(tagpoint, c));

		return uint256(keccak256(abi.encodePacked(
			tagpoint.X, tagpoint.Y,
			a.X, a.Y,
			b.X, b.Y
		)));
	}

	function Verify(uint256[8] memory pubkeys, uint256[2] memory tag, uint256[4] memory tees, uint256 seed, uint256 message )
		public view
		returns (bool)
	{
		require( pubkeys.length % 2 == 0 );
		require( pubkeys.length > 0 );

		Curve.G1Point memory M = Curve.HashToPoint(message);
		uint256 h = uint256(keccak256(abi.encodePacked(M.X, M.Y, tag[0], tag[1])));
		Curve.G1Point memory tagpoint = Curve.G1Point(tag[0], tag[1]);

		uint256 c = seed;
		for( uint256 i = 0; i < (pubkeys.length / 2); i++ )
		{
			uint256 j = i * 2;
			c = uint256(keccak256(abi.encodePacked(
					h,
					RingLink(
						Curve.G1Point(pubkeys[j], pubkeys[j+1]),
						M,
						tagpoint,
						tees[i],
						c
					))));
		}
		return c == seed;
	}
}