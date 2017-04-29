require_relative "hw6a.rb"

class TreasureLocation < Location
	attr_accessor :treasureLocked
	
	def initialize(name, desc)
		super(name,desc)
		@treasureLocked = true
    end
    
    def pretty_print
    	unless(treasureLocked) 
    		@desc = "You found treasure in the room!"
		end
        things = []
        paragraphs = [@desc]
        @things.each do |key, thing|
            if (not things.include? thing)
                paragraphs += [thing.describe(:world)]
                things += [thing]
            end
        end
        Game.pretty_print(paragraphs, @name)
        return self
    end
    
end


class Key < Item
	def initialize()
        super("key", "a key", "a key to something important, undoubtedly", "I dont think this line is relevant")
    end
	def use(args = [])
		if ((Game.location()).is_a?(TreasureLocation))
            (Game.location()).treasureLocked = false
            	puts "You found treasure in the room!"
            else print "There's nothing to unlock here", $/
		end
	end
end

class Talk < Action
    def initialize() @desc = "Converse with a monster" end
    def do(args = [])
        if (args.length < 1)
            puts "You feel pretty silly talking to yourself. Perhaps you should find someone to talk to."
        elsif Game.location.things.has_key?(args[0])
            thing = Game.location.things[args[0]]
            if thing.is_a? Monster
                thing.talk(Game.player)
            else
                print "Are you really trying to talk to a ", thing.name, "?", $/
            end
        else
            print "You can't talk to that.", $/
        end
    end
end

class Insult < Action
    def initialize() @desc = "Tell the monster how you really feel!" end
    def do(args = [])
        if (args.length < 1)
            puts "You insult the very air itself. It doesnt seem bothered"
        elsif Game.location.things.has_key?(args[0])
            thing = Game.location.things[args[0]]
            if thing.is_a? Monster
            	print "You tell ", thing.name, " just how ugly it is. They attack in retaliation!", $/
                thing.attack(Game.player)
            else
                print "Are you really trying to insult a ", thing.name, "?", $/
            end
        else
            print "You can't insult that.", $/
        end
    end
end

class Monster
	def talk(other)
		print "Oh hi there, thanks for not attacking me!", $/
	end
end

class FatalMonster < Monster
	def attack(other)
        abort "You may have bitten off more than you can chew."
    end
end

class ThiefMonster < Monster
	def attack(other)
		Game.player.inventory = [];
		puts "You attacked the monster, but he stole all your items!"
	end
end


ruins = DarkLocation.new('The Ruins','Toriels domain')
snowdin = Location.new('Snowdin','The snowy home of Papyrus and Sans')
waterfall = Location.new('Waterfall','Watch out for annoying dogs!')
hotland = Location.new('Hotland','Alphys and Undyne sitting in a tree')
core = DarkLocation.new('Core','The home of Mettaton and the last stop before New Home')
truelab = DarkLocation.new('True Laboratory','The site of Alphys experiments on DETERMINATION')
judgmenthall = TreasureLocation.new('Judgment Hall','The hallway where Sans waits to judge you')
newhome = TreasureLocation.new('New Home','The beginning and the end. Theres a faint hint of something glittering in a corner')

ruins.doors['east'] = snowdin
snowdin.doors['east'] = waterfall
waterfall.doors['west'] = snowdin
waterfall.doors['east'] = hotland
hotland.doors['west'] = waterfall
hotland.doors['east'] = truelab
hotland.doors['north'] = core
truelab.doors['west'] = hotland
core.doors['south'] = hotland
core.doors['north'] = judgmenthall
judgmenthall.doors['south'] = core
judgmenthall.doors['east'] = newhome
newhome.doors['west'] = judgmenthall
newhome.doors['south'] = ruins


toriel = FriendlyMonster.new('Toriel','Goat mom',nil)
flowey = FatalMonster.new('Flowey','Asriel Dreemurr',{"str" => 10})
robin = ThiefMonster.new('Robin','Robin',{"money" => 20})
undyne = Monster.new('Undyne','Undyne the Undying',{"determination" => 1})

newhome.things['Flowey'] = flowey
newhome.things['flowey'] = flowey
newhome.things['Asriel'] = flowey
newhome.things['asriel'] = flowey
ruins.things['Toriel'] = toriel
ruins.things['toriel'] = toriel
ruins.things['Goat'] = toriel
ruins.things['goat'] = toriel
hotland.things['Robin'] = robin
hotland.things['robin'] = robin
waterfall.things['Undyne'] = undyne
waterfall.things['undyne'] = undyne
waterfall.things['Undyning'] = undyne
waterfall.things['undying'] = undyne
lantern = Lantern.new()
key = Key.new()
g = Game.new(ruins,actions: {"talk" => Talk.new,"insult" => Insult.new},inventory: [lantern, key])




