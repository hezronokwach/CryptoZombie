pragma solidity >=0.5.0 <0.6.0;

// Importing the ZombieFactory contract to inherit its functionalities
import "./zombiefactory.sol";

// Defining an interface for the CryptoKitties contract to interact with it
contract KittyInterface {
    // Function signature for getKitty from CryptoKitties contract
    function getKitty(
        uint256 _id
    )
        external
        view
        returns (
            bool isGestating,
            bool isReady,
            uint256 cooldownIndex,
            uint256 nextActionAt,
            uint256 siringWithId,
            uint256 birthTime,
            uint256 matronId,
            uint256 sireId,
            uint256 generation,
            uint256 genes
        );
}

// The ZombieFeeding contract inherits from ZombieFactory
contract ZombieFeeding is ZombieFactory {
    // Address of the CryptoKitties contract on the Ethereum blockchain
    address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    // Creating an instance of the KittyInterface to interact with CryptoKitties
    KittyInterface kittyContract = KittyInterface(ckAddress);

    // Function to feed a zombie and multiply it with the target DNA
    function feedAndMultiply(
        uint _zombieId,
        uint _targetDna,
        string memory _species
    ) public {
        // Ensure the caller is the owner of the zombie
        require(msg.sender == zombieToOwner[_zombieId]);
        // Retrieve the zombie from the storage
        Zombie storage myZombie = zombies[_zombieId];
        // Ensure the target DNA is within the correct range
        _targetDna = _targetDna % dnaModulus;
        // Combine the DNA of the zombie and the target DNA
        uint newDna = (myZombie.dna + _targetDna) / 2;
        // If the species is a kitty, modify the new DNA to end with '99'
        if (
            keccak256(abi.encodePacked(_species)) ==
            keccak256(abi.encodePacked("kitty"))
        ) {
            newDna = newDna - (newDna % 100) + 99;
        }
        // Create a new zombie with the combined DNA
        _createZombie("NoName", newDna);
    }

    // Function to feed a zombie on a CryptoKitty
    function feedOnKitty(uint _zombieId, uint _kittyId) public {
        // Get the DNA of the CryptoKitty using its ID
        uint kittyDna;
        // Call the getKitty function on the CryptoKitties contract
        (, , , , , , , , , kittyDna) = kittyContract.getKitty(_kittyId);
        // Feed and multiply the zombie with the kitty's DNA
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }
}
