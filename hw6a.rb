require_relative "hw6.rb"

class FriendlyMonster < Monster
	def attack(other)
		print "I am not very fond of violence", $/
	end
end

class Lantern < Item
	attr_accessor :lit
	def initialize()
        super("lantern", "a lantern to light the way", "The lantern is not lit", "I dont think this line is relevant")
    end
	def use(args = [])
		if @lit == true
		then @lit = false
			@detail_text = "The lantern is not lit"
			print "The lantern has been successfully defused", $/
		else @lit = true
			@detail_text = "The lantern is lit"
			print "The lantern has been successfully lit", $/
		end
	end
end

class DarkLocation < Location
	attr_accessor :hiddenDesc
	
	def initialize(name, hiddenDesc)
        @name = name
        @desc = "It is too dark to see anything"
        @doors = {}
        @things = {}
        @hiddenDesc = hiddenDesc
        @dark = true
    end
	
	def pretty_print
		Game.player.inventory.each do |item|
            if (item.name == "lantern")
                if(item.lit == true)
                	@desc = @hiddenDesc
            	end
      		end
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

#l = Location.new('Snowdin','The snowy home of Papyrus and Sans')
#d = DarkLocation.new('Core','The home of Mettaton and the last stop before New Home')
#l.doors['north'] = d
#d.doors['south'] = l
#m = FriendlyMonster.new('Toriel','Goat mom',nil)
#l.things['Tori'] = m
#l.things['Mom'] = m
#l.things['Toriel'] = m
#l.things['toriel'] = m
#lantern = Lantern.new()
#g = Game.new(l,actions: {},inventory: [lantern])