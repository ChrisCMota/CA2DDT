// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract FoodSupplyAgreement {
    address public restaurant;
    address public supplier;
    uint public orderAmount;
    bool public orderPlaced;
    bool public orderFulfilled;

    struct Ingredient {
        uint quantity;
        uint pricePerUnit;
    }

    mapping(address => Ingredient) public ingredientDetails;
    address[] public ingredients; 

    event OrderPlaced(address indexed party, uint quantity, uint totalAmount);
    event OrderFulfilled(address indexed party, uint quantity, uint totalAmount);
    event OrderWithdrawn(address indexed party, uint amount);

    modifier onlyRestaurant() {
        require(msg.sender == restaurant, "You are not the restaurant");
        _;
    }

    modifier onlySupplier() {
        require(msg.sender == supplier, "You are not the supplier");
        _;
    }

    modifier orderNotPlaced() {
        require(!orderPlaced, "Order is already placed");
        _;
    }

    modifier orderIsPlaced() {
        require(orderPlaced, "No order is placed");
        _;
    }

    modifier orderIsFulfilled() {
        require(orderFulfilled, "Order is not fulfilled yet");
        _;
    }

    constructor(address _supplier) {
        restaurant = msg.sender;
        supplier = _supplier;
        orderPlaced = false;
        orderFulfilled = false;
    }

    function addIngredient(address _ingredient, uint _pricePerUnit) public onlyRestaurant {
        
        ingredientDetails[_ingredient] = Ingredient(0, _pricePerUnit);
        ingredients.push(_ingredient);
    }

    function placeOrder(address _ingredient, uint _quantity) public onlyRestaurant orderNotPlaced {
        Ingredient storage ingredient = ingredientDetails[_ingredient];
        require(_quantity > 0, "Quantity must be greater than zero");

        ingredient.quantity = _quantity;
        orderAmount += _quantity * ingredient.pricePerUnit;

        emit OrderPlaced(msg.sender, _quantity, orderAmount);

        orderPlaced = true;
    }

    function fulfillOrder() public onlySupplier orderIsPlaced {
        require(orderAmount > 0, "No pending order");

        orderFulfilled = true;
        emit OrderFulfilled(msg.sender, orderAmount, orderAmount);
    }

    function withdraw() public onlyRestaurant orderIsFulfilled {
    payable(restaurant).transfer(orderAmount);
    emit OrderWithdrawn(msg.sender, orderAmount);

    
    resetOrderState();
    }


    function resetOrderState() internal {
        orderPlaced = false;
        orderFulfilled = false;
        orderAmount = 0;

        
        for (uint i = 0; i < ingredients.length; i++) {
            ingredientDetails[ingredients[i]].quantity = 0;
        }
    }

    receive() external payable {}
}
