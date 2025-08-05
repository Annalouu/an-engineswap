Config = {
    debug = false, --- change this to true if you want to edit the code
    usePayments = true, --- false if you don't want to use payment
    RenewedBanking = false, --- true if you use renewed banking
    moneyType = "cash", --- payment method (bank or cash)
    defaultSoundPrice = 1000, --- price for original sound
    autoIntegrateToGarage = true, --- Automatic integration with garage script. Sound detection when vehicle is taken out.
    autoControlTime = 5 * 1000 --- Time in milliseconds to control the vehicle sound when taken out of garage.
}