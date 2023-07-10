# BozoFramework

**BozoFramework** is a work in progress framework that aims to provide realistic and unique resources for developers. It offers a range of functionalities for character creation, character data management, and various server-side functions. Please note that this framework is intended as a joke and should not be taken seriously.

## Features

### Character Creation

- Create new characters with customizable attributes such as first name, last name, date of birth (dob), and gender.

### Character Data

- Retrieve and update character data, including cash, bank balance, phone number, last location, inventory, job, and custom data fields.

### Names

- Generate random names for characters based on predefined algorithms.

## Server Functions

The BozoFramework provides the following server-side functions:

### `BozoCore.Functions.GetPlayer(player)`

This function retrieves the player information for the given player.

### `BozoCore.Functions.GetPlayers(getBy, value)`

This function retrieves a list of players based on the specified criteria. If no criteria are provided, it returns all players. The optional parameters `getBy` and `value` allow filtering the player list based on specific conditions.

- Example usage: `local players = BozoCore.Functions.GetPlayers("groups", "admin")`

### `BozoCore.Functions.GetUserDiscordInfo(discordUserId)`

This function retrieves Discord information for a given Discord user ID. It performs an HTTP request to the Discord API and returns the user's nickname, Discord tag, and roles.

- Example usage: `local discordInfo = BozoCore.Functions.GetUserDiscordInfo("1234567890")`

### `BozoCore.Functions.GetPlayerIdentifierFromType(type, player)`

This function retrieves the player identifier of the specified type for the given player. It iterates through the player's identifiers and returns the first one that matches the specified type.

- Example usage: `local identifier = BozoCore.Functions.GetPlayerIdentifierFromType("license", player)`

### `BozoCore.Functions.UpdateMoney(player)`

This function updates the cash and bank balance for the specified player. It retrieves the values from the database and triggers a client event to update the player's money display.

- Example usage: `BozoCore.Functions.UpdateMoney(player)`

### `BozoCore.Functions.TransferBank(amount, player, target, descriptionSender, descriptionReceiver)`

This function allows transferring money from one player's bank account to another player's bank account. It performs validation checks for the sender's account balance and the target player's existence.

- Example usage: `BozoCore.Functions.TransferBank(500, player, target, "Payment", "Received payment")`

## Client Functions

The BozoFramework provides the following client-side functions:

### `BozoCore.Functions.GetSelectedCharacter()`

This function retrieves the selected character for the client.

### `BozoCore.Functions.GetCharacters()`

This function retrieves the list of characters available for the client.

### `BozoCore.Functions.GetPlayersFromCoords(distance, coords)`

This function retrieves a list of players within a specified distance from the given coordinates. If no coordinates are provided, it uses the player's current position.

- Example usage: `local nearbyPlayers = BozoCore.Functions.GetPlayersFromCoords(10, vector3(0, 0, 0))`

### `GetCoreObject()`

This function retrieves the core object of the BozoFramework. It can be used to access other client functions and properties.

- Example usage: `local coreObject = GetCoreObject()`

## Acknowledgements

The BozoFramework is a satirical project and is not meant to be taken seriously. It was inspired by the ND-Framework and created for entertainment purposes only.

