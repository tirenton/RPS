// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract CommitReveal {

    struct Commit {
        bytes32 commit;
        uint64 block;
        bool revealed;
    }

    mapping (address => Commit) public commits;

    function commit(bytes32 dataHash) public virtual {
        commits[msg.sender].commit = dataHash;
        commits[msg.sender].block = uint64(block.number);
        commits[msg.sender].revealed = false;
        emit CommitHash(msg.sender, dataHash, commits[msg.sender].block);
    }


    event CommitHash(address sender, bytes32 dataHash, uint64 block);

    function reveal(bytes32 revealHash) public virtual  {
        require(commits[msg.sender].revealed == false, "Already revealed");
        require(getHash(revealHash) == commits[msg.sender].commit, "Hash mismatch");
        require(uint64(block.number) > commits[msg.sender].block, "Reveal too soon");
        require(uint64(block.number) <= commits[msg.sender].block + 250, "Reveal too late");

        commits[msg.sender].revealed = true;
        emit RevealHash(msg.sender, revealHash);
    }

    event RevealHash(address sender, bytes32 revealHash);

    function getHash(bytes32 data) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(data));
    }
}
