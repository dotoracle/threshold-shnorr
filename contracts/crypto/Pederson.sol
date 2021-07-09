pragma solidity >=0.4.19;

import "./Curve.sol";

library Pederson {
    /**
     * @dev        Generate Pedersen Commitment C = r * H + m * G using HashToPoint
     * @param      m         Message to commit to
     * @param      r         Random value
     * @param      h         Random h agreed upon by parties involved
     * @return               pedersen commitment
     */
    function commit(uint256 m, uint256 r, uint256 h) internal view returns (uint256[2] memory) {
        // Use random point initially to generate 2nd generator H
        Curve.G1Point memory H = Curve.HashToPoint(h);

        // Generate left point r * H
        Curve.G1Point memory lf = Curve.g1mul(H, r);

        // Generate right point m * g
        Curve.G1Point memory rt = Curve.g1mul(Curve.P1(), m);

        // Generate C = r * H + m * G
        Curve.G1Point memory c = Curve.g1add(lf, rt);

        return [c.X, c.Y];
    }

    /**
     * @dev        Generate Pedersen Commitment C = r * H + m * G using random generator
     * @param      a     Random point for generating another generator H
     * @param      m     Message to commit to
     * @param      r     Random value
     * @return           pedersen commitment
     */
    function commitWithGen(uint256 a, uint256 m, uint256 r) internal view returns(uint256[2] memory) {
        // Generate H = a * g
        Curve.G1Point memory H = Curve.g1mul(Curve.P1(), a);

        // Generate left point r * H
        Curve.G1Point memory lf = Curve.g1mul(H, r);

        // Generate right point m * g
        Curve.G1Point memory rt = Curve.g1mul(Curve.P1(), m);

        // Generate C = r * H + m * G
        Curve.G1Point memory c = Curve.g1add(lf, rt);

        return [c.X, c.Y];
    }

    /**
     * @dev        Generate Pedersen Commitment C = r * H + m * G using provided generator H
     * @param      H     Supposedly another random generator
     * @param      m     Message to commit to
     * @param      r     Random value
     * @return           pedersen commitment
     */
    function commitWithH(uint256[2] memory H, uint256 m, uint256 r) internal view returns(uint256[2] memory) {
        // Generate left point r * H
        Curve.G1Point memory H_point = Curve.G1Point({
            X: H[0],
            Y: H[1]
        });
        Curve.G1Point memory lf = Curve.g1mul(H_point, r);

        // Generate right point m * G
        Curve.G1Point memory rt = Curve.g1mul(Curve.P1(), m);

        // Generate C = r * H + m * G
        Curve.G1Point memory c = Curve.g1add(lf, rt);

        return [c.X, c.Y];
    }
    
    /**
     * @dev        Verify a pederson commitment by reconstructing commitment using an unsafe method (h should be hidden)
     * @param      commitment  The commitment
     * @param      m           Message committed to
     * @param      h           Input to HashToPoint
     * @param      r           Random value
     * @return     res         Success or failure
     */
    function verifyUnsafe(uint256[2] memory commitment, uint256 m, uint256 h, uint256 r) internal view returns(bool res)  {
        // Use random point initially to generate 2nd generator H
        Curve.G1Point memory H = Curve.HashToPoint(h);

        // Generate left point r * H
        Curve.G1Point memory lf = Curve.g1mul(H, r);

        // Generate right point m * g
        Curve.G1Point memory rt = Curve.g1mul(Curve.P1(), m);

        // Generate C = r * H + m * G
        Curve.G1Point memory c = Curve.g1add(lf, rt);

        return (c.X == commitment[0] && c.Y == commitment[1]);
    }
    
    /**
     * @dev        Verify a pederson commitment by reconstructing commitment
     * @param      commitment  The commitment
     * @param      m           Message committed to
     * @param      r           Random value
     * @param      a           Random value to generator random generator H
     * @return     res         Success or failure
     */
    function verifyWithGen(uint256[2] memory commitment, uint256 m, uint256 r, uint256 a) internal view returns(bool) {
        // Generate H = a * g
        Curve.G1Point memory H = Curve.g1mul(Curve.P1(), a);

        // Generate left point r * H
        Curve.G1Point memory lf = Curve.g1mul(H, r);

        // Generate right point m * g
        Curve.G1Point memory rt = Curve.g1mul(Curve.P1(), m);

        // Generate C = r * H + m * G
        Curve.G1Point memory c = Curve.g1add(lf, rt);

        return (c.X == commitment[0] && c.Y == commitment[1]);
    }

    /**
     * @dev        Verify a pederson commitment by reconstructing commitment
     * @param      commitment  The commitment
     * @param      m           Message committed to
     * @param      r           Random value
     * @param      H           Random generator
     * @return     res         Success or failure
     */
    function verifyWithH(uint256[2] memory commitment, uint256 m, uint256 r, uint256[2] memory H) internal view returns(bool)  {
        // Generate left point r * H
        Curve.G1Point memory H_point = Curve.G1Point({
            X: H[0],
            Y: H[1]
        });
        Curve.G1Point memory lf = Curve.g1mul(H_point, r);

        // Generate right point m * g
        Curve.G1Point memory rt = Curve.g1mul(Curve.P1(), m);

        // Generate C = r * H + m * G
        Curve.G1Point memory c = Curve.g1add(lf, rt);

        return (c.X == commitment[0] && c.Y == commitment[1]);
    }
}
