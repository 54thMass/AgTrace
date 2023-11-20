# AgTrace
A simply supply chain traceability application (draft for review).
# Corn Supply Chain Tracking Smart Contract - README

## Overview

This smart contract, named `AgTrace`, is designed to track the supply chain of corn crops for a private company, Hermanos Tortilla (HT). It allows HT to monitor the freshness and organic status of corn purchased from a network of exclusive corn farmers. The contract is implemented in Solidity, a language for developing smart contracts on the Ethereum blockchain.

## Contract Structure

The contract consists of two main parts: `AgTrace` and `AgWarehouse`. `AgTrace` is responsible for tracking the corn crop's journey from harvest to its final destination, while `AgWarehouse` handles inventory management and quality checks.

### AgTrace

- `AgTrace` is the main contract responsible for tracking corn crops.
- It defines the structure of a corn crop and maintains mappings to store crop data and shipping timestamps.
- Farmers can register their information when they harvest a crop.
- Hermanos Tortilla (HT) can check the freshness and organic status of shipments and decide whether to accept or refuse them.
- It assigns freshness levels to corn crops based on their storage time.
- Various helper functions generate random values for attributes like GMO level, organic status, shipping time, and more.

### AgWarehouse

- `AgWarehouse` inherits from `AgTrace` and extends its functionality.
- It maintains an inventory of corn crops accepted by HT.
- HT can check shipments against specific criteria to determine whether to buy the corn or refuse it.
- The contract includes functions to buy corn and add it to the Hermano Inventory or refuse the shipment.

## Usage Instructions

To use this smart contract effectively, follow these steps:

1. Deploy the contract on the Ethereum blockchain.

2. Register Corn Farmers:
   - Only HT should be allowed to register corn farmers using the `_registerCornFarmer` function.
   - This function adds eligible corn farmers to the contract's list of farmers.

3. Harvest Corn Crops:
   - Corn farmers can use the `harvestCrop` function to register information when they harvest a crop.
   - This function generates a new shipment ID, adds the crop to the `CornCrops` mapping, and records various attributes such as origin, GMO level, organic status, shipment weight, and timestamps.

4. Check Shipments:
   - HT can use the `checkShipment` function to evaluate the quality of corn shipments.
   - The function checks criteria like freshness, weight, origin, and organic status.
   - If the shipment meets the criteria, HT can buy the corn and add it to the Hermano Inventory. Otherwise, the shipment is refused.

5. View Data:
   - The contract provides functions to view information about corn crops, including shipment details and shipping timestamps.
   - You can use the `viewCornCrops` and `viewAllShippingTimestamps` functions to retrieve data.

## Smart Contract Structure

The smart contract is divided into separate parts to manage different aspects of the corn supply chain. This modular approach helps maintain code clarity and separation of concerns. The main functionalities include:

- **Registration**: Registering corn farmers and tracking their information.

- **Harvest and Tracking**: Registering harvested crops, generating shipment IDs, and tracking crop attributes and timestamps.

- **Quality Check**: Evaluating corn shipments against specific criteria to determine whether to accept or refuse them.

- **Inventory Management**: Managing the inventory of accepted corn crops and updating ownership and timestamps.

## Purpose

The primary purpose of this smart contract is to enable HT to source fresh and organic corn for its tortilla production. It achieves this by:

- Tracking the journey of corn crops from harvest to final destination.
- Assessing the freshness, origin, and organic status of corn shipments.
- Allowing HT to make informed decisions about purchasing corn.

## Features

The contract offers the following features:

- Tracking all corn crops shipped to HT, including details like shipment ID, origin, GMO level, organic status, shipment weight, timestamps, freshness level, and ownership.

- Maintaining an inventory of corn crops accepted by HT.

- Evaluating shipments against predefined criteria and enabling HT to buy corn or refuse shipments.

## Benefits

- Enhanced Transparency: HT gains transparency into the corn supply chain, ensuring that they source fresh and organic corn for their products.

- Quality Assurance: The contract helps maintain quality standards by allowing HT to refuse shipments that do not meet their criteria.

- Efficient Inventory Management: Hermano Inventory keeps track of accepted corn crops, making it easier for HT to manage their supply.

## Future Improvements

1. **Events and Logging**: Consider adding events and logs to capture important contract activities, making it easier to monitor and analyze the supply chain.

2. **Security Audits**: Perform security audits to identify and mitigate potential vulnerabilities in the contract code.

3. **User Interface**: Develop a user interface or DApp to interact with the contract, making it more user-friendly for HT and corn farmers.

4. **Optimizations**: Optimize the contract for gas efficiency to reduce transaction costs.

5. **Additional Features**: Consider adding features such as notifications, alerts, and notifications to improve user experience.

## License

This smart contract is released under the MIT License. See the SPDX-License-Identifier at the beginning of the code for details.

---

**Note:** This README provides an overview of the smart contract's functionality and purpose. Additional details, improvements, and user interfaces can be developed to enhance its usability and efficiency.
