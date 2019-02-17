pragma solidity >0.4.8 <0.6.0;

contract RNG{
    uint nonce;

    function generate(uint32 limit) public returns (uint) {
        nonce++;
        return uint(keccak256(abi.encodePacked(now, msg.sender, nonce))) % limit;
    }
}