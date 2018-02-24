pragma solidity ^0.4.18;

/**
 * This contract is largely borrowed from the Ownable.sol example contract
 * in the Open Zeppelin libraries.
 * 
 * The contract is meant for use with paintings.
 * the contract address is given to a painting at the time of deployment. 
 * (Probably a sort of sticker on the painting's back which shows the contract address.)
 *
 * The legal owner of the painting, as defined in this smart contract, 
 * is the individual who can sign a transaction with the address designated 'owner'. 
 *
 * To transfer ownership, the owner must set a sale price and a whitelisted new owner.
 * The new owner can claim ownership by posting the requested amount. 
 *
 * Current version specifies an artist address as a means of verifying the work's authenticity.
 * Future versions of this contract will include terms that grant the artist a percentage of each resale.
 *  
 */

contract artOwnable {
        
        address public artist; 
        address public owner;
        address public purchaser;
        uint public price;
        bool public forSale;

        event OfferOfSale(address indexed currentOwner, address indexed offeredTo, uint indexed salePrice);
        event OfferRescinded();
        event OfferAccepted(address indexed purchaser);
        event OwnershipTransferred(address indexed newOwner);
        event AuthenticityVerified();


        /**
         * The artist sets her address and becomes the owner at the contract deployment.
         * 
         */
        function artOwnable() public {
                artist = msg.sender;
                owner = artist;
                price = 0;
                forSale = false;
            }


        /**
         * Restrict certain functions to the owner, the artist, or the purchaser
         */
        modifier onlyOwner() {
                require(msg.sender == owner);
                _;
            }

        modifier onlyArtist() {
                require(msg.sender == artist);
                _;
            }

        modifier onlyPurchaser() {
                require(msg.sender == purchaser);
                _;
            }


        /**
         * The current owner of the painting is the only one who can initiate a transfer of ownership.
         * 
         * Only sales which are higher than the previous sale price are permitted.
         * 
         * 
         */
        function makeOffer(address _offeredTo, uint _minPrice) public onlyOwner {
                require(_minPrice >= price);
                purchaser = _offeredTo;
                price = _minPrice; // Making an offer irreversibly raises the price regardless of whether the offer is accepted or not. Caveat Venditor. 
                forSale = true;
                OfferOfSale(msg.sender, purchaser, price);
            }

        function rescindOffer() public onlyOwner {
                forSale = false;
                purchaser = address(0);
                OfferRescinded();
            }

        function claimOffer() public payable onlyPurchaser {
                require(msg.value >= price);
                require(forSale);
                purchaser = address(0);
                owner.transfer(msg.value);
                owner = msg.sender;
                forSale = false;
                OwnershipTransferred(msg.sender);
            } 

        /**
         * In the event of a dispute of ownership or another painting claiming to be the one specified in this contract, 
         * The artist alone may inspect the painting in question and call this function to publicly verify its authenticity. 
         */
        function verifyAuthenticity() public onlyArtist {
                AuthenticityVerified();
            }
    }
