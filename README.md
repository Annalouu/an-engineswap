# An-engineswap
- Engine swap script For QBcore & ESX
- My discord: https://discord.gg/94FQvA84vB

# Feats
- Custom Engine.
- Custom Sounds.
- Fully Server sync using Onesync state bags.
- Cleaned and optimized and removed all the useless functions.
- If you are an admin you can do ```/carsound``` to open the engine swap menu without setting a zone.
- Create a new zone using the command ```/createzone``` in the game.
- View a list of all zones using the command ```/zonelist```.
- Add a new sound to the swap engine list using the command ```/addsound```.
- view all sound lists using the command ```/soundlist```.
- Each zone has its own authorized job.
- You can make it so only bosses of the jobs can engine swap.
- You can add more zones for more mechanic shops.

# Install
- You need to download: https://github.com/Annalouu/an-engines
- Drag an-engineswap and an-engines to your resource folder
- ensure an-engineswap and an-engines in the server.cfg (After qb-core or es_extended and ox_lib)

# Image
![image](https://cdn.discordapp.com/attachments/837147253562146846/1029785285908766720/unknown.png)
Video: [2023-12-08_15-19-18.mp4](https://cdn.discordapp.com/attachments/1182603049248763944/1182603055317925899/2023-12-08_15-19-18.mp4?ex=66f129ec&is=66efd86c&hm=b0dafdf3be4a3b92bbb2d40eee10c3a37f1cdc4f71c6601c3b39950035712722&)

# dependency
- ox_lib
- QBcore & ESX
- an-engines: https://github.com/Annalouu/an-engines

# If you use the Nopixel car subscription 
Replace these sound cars with these
```lua
return {
	car = {
		issi2 = {
			price = 0,
			label = "Coupe Engine #2"
		},
		rhapsody = {
			price = 0,
			label = "Coupe Engine #3"
		},
		cogcabrio = {
			price = 0,
			label = "Coupe Engine #4"
		},
		exemplar = {
			price = 0,
			label = "Coupe Engine #5"
		},
		f620 = {
			price = 0,
			label = "Coupe Engine #6"
		},
		felon = {
			price = 0,
			label = "Coupe Engine #7"
		},
		sentinel = {
			price = 0,
			label = "Coupe Engine #8"
		},
		sentinel = {
			price = 0,
			label = "Coupe Engine #8"
		},
		zion = {
			price = 0,
			label = "Coupe Engine #9"
		},
		coquette3 = {
			price = 0,
			label = "Muscle Engine #10"
		},
		dominator = {
			price = 0,
			label = "Muscle Engine #11"
		},
		dominator2 = {
			price = 0,
			label = "Muscle Engine #12"
		},
		ruiner = {
			price = 0,
			label = "Muscle Engine #13"
		},
		rebel = {
			price = 0,
			label = "Diesel Engine #14"
		},
		sandking = {
			price = 0,
			label = "Diesel Engine #15"
		},
		mesa3 = {
			price = 0,
			label = "Diesel Engine #16"
		},
		dubsta3is = {
			price = 0,
			label = "Diesel Engine #17"
		},
		stratum = {
			price = 0,
			label = "Sport Engine #18"
		},
		alpha = {
			price = 0,
			label = "Sport Engine #19"
		},
		banshee = {
			price = 0,
			label = "Sport Engine #20"
		},
		blista = {
			price = 0,
			label = "Sport Engine #21"
		},
		blista2 = {
			price = 0,
			label = "Sport Engine #22"
		},
		bufallo2 = {
			price = 0,
			label = "Sport Engine #23"
		},
		bufallo3 = {
			price = 0,
			label = "Sport Engine #24"
		},
		carbonizzare = {
			price = 0,
			label = "Sport Engine #25"
		},
		comet = {
			price = 0,
			label = "Sport Engine #26"
		},
		elegy2 = {
			price = 0,
			label = "Sport Engine #27"
		},
		fusilade = {
			price = 0,
			label = "Sport Engine #28"
		},
		fusilade = {
			price = 0,
			label = "Sport Engine #28"
		},
		jester2 = {
			price = 0,
			label = "Sport Engine #28"
		},
		massacro2 = {
			price = 0,
			label = "Sport Engine #29"
		},
		penumbra = {
			price = 0,
			label = "Sport Engine #30"
		},
		sultan = {
			price = 0,
			label = "Sport Engine #31"
		},
		np02asiani6 = {
			price = 0,
			label = "Sport Engine #32"
		},
		np03asianf4 = {
			price = 0,
			label = "Sport Engine #33"
		},
		np04eurov8 = {
			price = 0,
			label = "Sport Engine #34"
		},
		coquette2 = {
			price = 0,
			label = "Sport Classic Engine #35"
		},
		monroe = {
			price = 0,
			label = "Sport Classic Engine #36"
		},
		monroe = {
			price = 0,
			label = "Sport Classic Engine #37"
		},
		stinger = {
			price = 0,
			label = "Sport Classic Engine #38"
		},
		adder = {
			price = 0,
			label = "Super Engine #39"
		},
		bullet = {
			price = 0,
			label = "Super Engine #40"
		},
		cheetah = {
			price = 0,
			label = "Super Engine #41"
		},
		entityxf = {
			price = 0,
			label = "Super Engine #42"
		},
		osiris = {
			price = 0,
			label = "Super Engine #43"
		},
		vacca = {
			price = 0,
			label = "Super Engine #44"
		},
		zentorno = {
			price = 0,
			label = "Super Engine #45"
		},
		np01eurov10 = {
			price = 0,
			label = "Super Engine #46"
		},
		np05itasuperv8 = {
			price = 0,
			label = "Super Engine #47"
		},
	},
	motorcycle = {
		hexer = {
			price = 0,
			label = "Cruiser/Chopper #1"
		},
		bagger = {
			price = 0,
			label = "Cruiser/Chopper #2"
		},
		daemon = {
			price = 0,
			label = "Cruiser/Chopper #3"
		},
		bati = {
			price = 0,
			label = "Sport bike #1"
		},
		double = {
			price = 0,
			label = "Sport bike #2"
		},
		ruffian = {
			price = 0,
			label = "Sport bike #3"
		},
		vader = {
			price = 0,
			label = "Sport bike #4"
		},
		bati2 = {
			price = 0,
			label = "Sport bike #5"
		},
		carbonrs = {
			price = 0,
			label = "Sport bike #6"
		},
		hakuchou = {
			price = 0,
			label = "Sport bike #7"
		},
		
	},
}
```

# Credits
Thanks to these people to contribute.

- Thanks to https://github.com/SerenaKing for doing some refactoring after the initial release.
- Thanks to https://github.com/reyyghi for refactoring and ESX compatibility.
