// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "./CommitReveal.sol";
import "./TimeUnit.sol";

contract RPSLS is CommitReveal, TimeUnit {
    uint public numPlayer = 0;
    uint public reward = 0;
    uint public numRevealed = 0;
    uint256 public revealDeadline; // เวลาสูงสุดที่ต้อง Reveal

    struct Player {
        bool hasRevealed;
        uint choice;
    }

    mapping(address => Player) public players;
    address[] public playerAddresses;

    address constant allowed1 = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    address constant allowed2 = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    address constant allowed3 = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
    address constant allowed4 = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;

    function isAllowed(address _addr) internal pure returns (bool) {
        return (_addr == allowed1 || _addr == allowed2);
    }

    // ให้ผู้เล่นเข้าร่วมเกมโดยต้องส่ง 1 ether
    function addPlayer() public payable {
        require(isAllowed(msg.sender), "Not allowed to play");
        require(numPlayer < 2, "Game already has 2 players");
        require(msg.value == 1 ether, "Must send exactly 1 ether");

        players[msg.sender] = Player({
            hasRevealed: false,
            choice: 5
        });

        playerAddresses.push(msg.sender);
        numPlayer++;
        reward += msg.value;

        // กำหนดเวลา Reveal (เช่น 5 นาที)
        if (numPlayer == 2) {
            setStartTime();
            revealDeadline = block.timestamp + 5 minutes;
        }
    }

    // **ผู้เล่น commit ค่า hash**
    function commit(bytes32 hashedChoice) public override {
        require(numPlayer == 2, "Need 2 players");
        require(commits[msg.sender].commit == bytes32(0), "Already committed");

        commits[msg.sender].commit = hashedChoice;
        commits[msg.sender].block = uint64(block.number);
        commits[msg.sender].revealed = false;
        emit CommitHash(msg.sender, hashedChoice, commits[msg.sender].block);
    }

    // **ผู้เล่น reveal (ใช้ค่าก่อน hash)**
    function reveal(bytes32 revealHash) public override {
        require(numPlayer == 2, "Need 2 players");
        require(players[msg.sender].hasRevealed == false, "Already revealed");

        // คำนวณค่า hash ใหม่จากค่าที่ reveal มา
        bytes32 computedHash = getHash(revealHash);
        require(computedHash == commits[msg.sender].commit, "Hash mismatch");

        // ดึงค่า Choice จาก Hash โดย mod 5 เพื่อให้ได้ค่า 0-4
        uint choice = uint(uint256(revealHash) % 5);
        players[msg.sender].choice = choice;
        players[msg.sender].hasRevealed = true;
        numRevealed++;

        emit RevealHash(msg.sender, revealHash, choice);

        // หากผู้เล่นทั้งสองคน reveal แล้ว ให้ตัดสินผลทันที
        if (numRevealed == 2) {
            _checkWinnerAndPay();
        }
    }

    // ✅ **บังคับให้เกมจบเมื่อมีผู้เล่นไม่ Reveal ตามเวลา**
    function forceReveal() public {
        require(numPlayer == 2, "Game is not started");
        require(block.timestamp >= revealDeadline, "Reveal deadline not reached");

        address payable player1 = payable(playerAddresses[0]);
        address payable player2 = payable(playerAddresses[1]);

        bool player1Revealed = players[player1].hasRevealed;
        bool player2Revealed = players[player2].hasRevealed;

        if (player1Revealed && !player2Revealed) {
            player1.transfer(reward); // คืนเงินให้ผู้เล่นที่ reveal
        } else if (!player1Revealed && player2Revealed) {
            player2.transfer(reward); // คืนเงินให้ผู้เล่นที่ reveal
        } else {
            // ถ้าไม่มีใคร reveal เลย ให้คืนเงินทั้งสองฝ่าย
            player1.transfer(1 ether);
            player2.transfer(1 ether);
        }

        _resetGame();
    }

    event RevealHash(address sender, bytes32 revealHash, uint choice);

    // ฟังก์ชันสำหรับยกเลิกเกมและคืนเงินให้ผู้เล่น
    function cancelMatch() public {
        require(numPlayer > 0, "No players to refund");

        for (uint i = 0; i < playerAddresses.length; i++) {
            address payable player = payable(playerAddresses[i]);
            if (players[player].hasRevealed == false) {
                player.transfer(1 ether); // คืนเงินเฉพาะคนที่ยังไม่ได้ reveal
            }
        }

        _resetGame();
    }

    // ตรวจสอบผู้ชนะและแจกเงินรางวัล
    function _checkWinnerAndPay() private {
        uint p0Choice = players[playerAddresses[0]].choice;
        uint p1Choice = players[playerAddresses[1]].choice;
        address payable account0 = payable(playerAddresses[0]);
        address payable account1 = payable(playerAddresses[1]);

        uint diff = (5 + p0Choice - p1Choice) % 5;
        if (diff == 1 || diff == 2) {
            account0.transfer(reward);
        } else if (diff == 3 || diff == 4) {
            account1.transfer(reward);
        } else {
            account0.transfer(reward / 2);
            account1.transfer(reward / 2);
        }

        _resetGame();
    }

    // รีเซ็ตสถานะเกมให้สามารถเล่นใหม่ได้
    function _resetGame() private {
        delete players[playerAddresses[0]];
        delete players[playerAddresses[1]];
        delete playerAddresses;
        numPlayer = 0;
        reward = 0;
        numRevealed = 0;
    }
}
