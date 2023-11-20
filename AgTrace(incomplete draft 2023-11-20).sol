//SPDX-License-Identifier: MIT
/*
To build
1. How and where to use payable? --Use payable for HT to buy the corn from the farmers?
*/

pragma solidity >=0.7.0 < 0.9.0;

//@title This contract tracks corn crops supply chain for a private company
//@author Nadir Khan
//@note My 1st ever smart contract :D. November 2023
contract AgTrace{

address[] cornFarmers;
enum OriginState{Iowa, Illinois, Nebraska, Minnesota}
enum Freshness{VeryFresh, Fresh, Old, Rancid}
uint shipmentID = 0;
address payable HermanoTortilla;

struct cornCrop {
uint _shipmentID;
OriginState originFarm;
address originFarmer;
uint _gmoLevel;
bool organicStatus;
uint8 shipmentWeight;
uint harvestTime;
uint arrivalTime;
uint shippingTime;
uint timeStored;
Freshness freshnessLevel;
address _currentOwner;
}

mapping(uint => cornCrop) public CornCrops;
mapping(uint => mapping(string => uint)) public shippingTimestamps;

//@dev modifier so only HT address can call checkShipment
modifier onlyHermano(){
require(msg.sender == HermanoTortilla, "Caller is not Hermano Tortilla!");
_;
}

//@dev This modifier checks if msg.sender exists in cornFarmers[]
modifier onlyCornFarmers(){
bool isCornFarmer = false;
for(uint i=0;i<cornFarmers.length;i++){
if(cornFarmers[i] == msg.sender){
isCornFarmer = true;
break;
}
}
require(isCornFarmer == true, "Caller is not a corn farmer!");
_;
}

//@dev Allows the company to register new corn farmers
function _registerCornFarmer(address) external{ //TO DO: Only HT should be able to call this
cornFarmers.push(msg.sender);
}

//@dev Allows farmers to register information when they harvest a crop
//@dev creates new shipment ID, adds the crop to CornCrops[], stores the farmer, shipment ID, origin farm, GMO level, organic status,
//@dev generates crop weight, and the harvest time. 
//@dev shipping time is stored in shippingTimestamps[] mapping
//@dev crop _sendToWarehouse called on the shipmentID
//@note the organic status, origin farm, and crop weight are generated randomly 
function harvestCrop(address _cornFarmer) external onlyCornFarmers{
uint localShipmentID = _generateShipmentID();
cornCrop storage newCrop = CornCrops[shipmentID];
newCrop.originFarmer = _cornFarmer;
newCrop._shipmentID = localShipmentID;
newCrop.originFarm = _generateRandomState();
uint8 gmoLevel = _generateGMOLevel();
newCrop._gmoLevel = gmoLevel; 
newCrop.organicStatus = _certify(gmoLevel);
newCrop.shipmentWeight = _generateWeight();
uint harvestTime = block.timestamp;
shippingTimestamps[shipmentID]["Harvest Time:"] = harvestTime; //store the harvest time and event in the shippingTimes mapping.
newCrop.harvestTime = harvestTime;
_sendToWarehouse(localShipmentID);
}

function viewCornCrops(uint id) internal view returns(cornCrop memory){
return CornCrops[id];
}

// Function to retrieve all shipping timestamps for a given shipment ID
    function viewAllShippingTimestamps(uint shipmentID) external view returns (mapping(string => uint) memory) {
        require(shipmentID > 0, "Invalid shipmentID");

        // Return the entire mapping for the specified shipment ID
        return shippingTimestamps[shipmentID];
    }

//@dev assigns an arrivalTime and stores it as member in CornCrops[]. arrivalTime is sum of the harvest time and shipping time together.
function _sendToWarehouse(uint _shipmentID) internal {
CornCrops[_shipmentID].shippingTime = _generateShippingTime();
uint arrivalTime = (shippingTimestamps[_shipmentID]["Harvest Time:"]) + (CornCrops[_shipmentID].shippingTime); // Can these two numbers be added properly?
shippingTimestamps[_shipmentID]["Arrival at Warehouse Silo:"] = arrivalTime;
CornCrops[_shipmentID].arrivalTime = arrivalTime;
}

//@dev generates random shipping time
function _generateShippingTime() private view returns(uint8){
return uint8((uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % 61));
}

//@dev this private function "certifies" if a crop's GMO Level is organic or not.
//@note <100 is arbitrary
function _certify(uint8 _gmoLevel) private pure returns(bool organic){
if (_gmoLevel <100){
return true;
}
return false;
}

//@dev this private function creates a increments the shipmentID state variable. Stored as member of a new CornCrop struct, 
//@dev stored in CornCrops[] and shippingTimestamps[]
function _generateShipmentID() private returns(uint){
    shipmentID = shipmentID +1;
    return shipmentID;
    }

//@dev this private function randomly creates a GMO Level. Stored in used by _certify to check organic status.
function _generateGMOLevel() private view returns (uint8 gmoLevel){
    return uint8((uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % 256));
    }
    
//@dev generates a random # and returns enum OriginState. Stored as member of CornCrop struct. 
function _generateRandomState() private view returns (OriginState){
    uint randState = (uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % 4);
    if (randState == 0){
        return OriginState.Iowa;
    } else if (randState == 1){
return OriginState.Minnesota;
    }else if (randState == 2){
return OriginState.Illinois;
    }else {
        return OriginState.Nebraska;
    }
    }

//@dev generates a random weight for a crop. Stored as member of CornCrop.
function _generateWeight() private view returns(uint8){
return uint8((uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % 256));
}

}
contract AgWarehouse is AgTrace{

mapping(uint => cornCrop) public HermanoInventory;

//@dev checks if a shipment passes HT criteria
//@dev if shipment passes check, _buyCorn called (crop is pushed to Hermano Inventory, shippingTimestamps[] updated, owner changes to HT)
//@dev if shipment fails check, _refuseShipment called (crop returned to originFarmer, shippingTimestamps[] updated)
function checkShipment(uint _shipmentID) external onlyHermano returns(string memory){//is external correct modifier?
    _assignFreshness(_shipmentID);
    Freshness cropFreshness = CornCrops[_shipmentID].freshnessLevel;
    OriginState _originState = CornCrops[_shipmentID].originFarm;
    if(cropFreshness == Freshness.VeryFresh || cropFreshness == Freshness.Fresh){
        if(CornCrops[_shipmentID].shipmentWeight >= 300){
            if(_originState == OriginState.Iowa || _originState == OriginState.Nebraska){
                if(CornCrops[_shipmentID].organicStatus == true){
                    _buyCorn(CornCrops[_shipmentID]);
                    return("Shipment PURCHASED by Hermano Tortilla");
                    }
                }
            }
        }
        _refuseShipment(CornCrops[_shipmentID]);
        return("Shipment REFUSED by Hermano Tortilla");
       }

//@dev Calculates and assigns a freshness level to a corn crop based on its total storage time.
//@note The time thresholds used in the freshness evaluation (30, 60, 90) are arbitrary
//@param _shipmentID The unique identifier of the corn crop.
function _assignFreshness(uint _shipmentID) private{
CornCrops[_shipmentID].timeStored = CornCrops[_shipmentID].arrivalTime + _generateCheckingDelay();
uint totalTimeStored =  CornCrops[_shipmentID].timeStored;

if(totalTimeStored < 30){
    CornCrops[_shipmentID].freshnessLevel = Freshness.VeryFresh;
} else if(totalTimeStored <= 60) {
CornCrops[_shipmentID].freshnessLevel = Freshness.Fresh;
} else if(totalTimeStored <= 90) {
CornCrops[_shipmentID].freshnessLevel = Freshness.Old;
} else {
CornCrops[_shipmentID].freshnessLevel = Freshness.Rancid;
}
}

//@dev Adds purchased crop to Hermano Inventory, changes crop owner to Hermano Tortilla, and adds timestamp of the purchase to shippingTimestamps
function _buyCorn(cornCrop memory crop) internal{
shippingTimestamps[crop._shipmentID]["Purchased by HT:"] = block.timestamp;
HermanoInventory[crop._shipmentID] = crop; 
crop._currentOwner = HermanoTortilla;
}

//@dev Assigns crop owner as original farmer, adds the timestamp of the refusal to shippingTimestamps
function _refuseShipment(cornCrop memory crop) internal{
shippingTimestamps[crop._shipmentID]["REFUSED by HT:"] = block.timestamp;
crop._currentOwner = crop.originFarmer;
}

//@dev generates random checking delay
function _generateCheckingDelay() private view returns(uint8){
return uint8((uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % 16));
}

/*complete this checkInventory function
function checkHermanoInventory() private internal { // confirm visibility modifier

}*/

}
/*
Background: Hermanos Tortilla is a large tortilla snack company in the United States. 
HT wants to start a new organic tortilla product line. HT seeks to source only the freshest and best organic corn across their network of exclusive corn farmers.
HT is looking for a blockchain based solution to track the freshness and organic nature of the corn they purchase.
HT is only willing to source organic crops that were harvested less than 1 month ago. 
All other crops are refused and sent back to the corn farmer to be sold to someone else.

Purpose of DApp:  Track a corn crop's journey from harvest to its final destination, tracking the time,to its final end use.

Features of DApp:

a) See all corn crops shipped to HT. View their Shipment ID, State of Origin, Address of the Origin Farmer, GMO Level,
Organic or not, Shipment weight, harvest time, arrival time, time store, freshness level and current owner.

b) See all corn crops accepted (HermanoInventory Mapping) and refused by HT (???)

c) 

Benefits of DApp:

Major functions:

1. harvestCrop:
2. sendToStorage:
3. checkShipment:
4. buycorn;
5. addHermanoInventory:

To add:
--original farmer of a cornCrop; ?
--total weight/bushels of a harvest;
--Timed feature that constantly randomly creates a supply of corn with different attributes.
-events/emits?


Questions:
--How should I subdivide the smart contracts. Should the private functions be in a separate SC and be inherited by main one?

To Do:
--Security check..
--Add comments in NatSec format
*/

