import "../src/TestToken.sol";
import "forge-std/Script.sol";
import "../src/PoolManager.sol"; 

pragma solidity ^0.8.24;
contract Deploy is Script {
    function run() public {
        vm.startBroadcast();
        TestToken token = new TestToken();
        // uint256 tickSpacing = 500000;
        address tickSpacing = address(this);
        PoolManager poolManager = new PoolManager(tickSpacing);
        vm.stopBroadcast();
        console.log("TestToken at:", address(token));
        console.log("PoolManager at:", address(poolManager));
    }
}
