# LBR
Lot By Risk (LBR) - is a trading panel for MetaTrader 4

#Link to marketplace: https://www.mql5.com/ru/market/product/56019

Trading panel Lot by Risk is designed for manual trading. This is an alternative means for submitting orders.

The first feature of the panel is convenient placement of orders using control lines. The second feature is the calculation of the volume of the transaction for a given risk in the presence of a stop line loss.

#Control lines are set using hotkeys:

take profit - default key T;
price - default key P;
stop loss - default key S;

You can configure the keys yourself in the settings of the trading panel.

#Work algorithm:

1) – place the levels in the desired places (it is not necessary to place all the levels);
2) – indicate the risk (optional);
3) – press the green send button order ;
4) – wait until an order is placed, or an alert appears with an error message;
5) – if we want to close all orders for the current symbol, linked by the magician to the adviser, then press the close button orders.

Don't press the send button too many times order. One time is enough. After the order is placed, the button will take the “not pressed” state.
To send an order with a risk calculation, be sure to set the stop line loss and set the risk in the " Risk " field of the trading panel. Otherwise, the order will be placed with the minimum lot for the current trading instrument.
The risk is calculated from the account balance. A 100% risk cannot be made due to broker restrictions related to the specifics of margin trading.
Fractional numbers are allowed in the " Risk " field (for example, you can trade with the risk of 0.5% of the balance).
If the specified risk is below the allowed lot, then the order will be placed with the minimum lot for the current trading instrument.
To place a panel order, the take line must be present profit or stop loss.
If the price line is not placed, then the order is placed according to the market .
If stop loss is not set, then orders will be placed with the minimum lot for the current trading instrument.
If stop loss is specified, but the risk is not specified in the « Risk » field, then the order will also be placed with a minimum volume .
Pending orders are placed indefinitely.
To trade the minimum lot - just delete the contents of the " Risk " field.

#inputs:

magic = 111 - magic number for orders;
slip page = 5 – slippage for market orders (set in pips);
comment = “ ” – comment to placed orders;
font = 7 – font for graphic objects;
HK_TP _ = “ T ” – hotkey for control level take profit (only A - Z , a - z , 0-9);
HK_SL _ = “ S ” – hotkey for control level stop loss (only A - Z , a - z , 0-9);
HK_PR _ = “ P ” – hotkey for control level price open (only A - Z , a - z , 0-9).

#IMPORTANT!!!
1) Hotkey symbols must be different from each other.
2) To place a panel order, the take line must be present profit OR stop loss.
