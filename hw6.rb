# CSE 413 16au Assignment 6 provided code
# Edit these comments to supply your name and make other appropriate changes

# readline provides nice command-line editing for text input
require 'readline'

# BASE: Thing
# Some kind of object in the game. Could be a monster, item, or what-have-you.
# The important thing is that it has several different ways of describing itself.
# Subclasses can rely on the default behavior (using the text passed in to the
# Thing constructor) or they can override for their own needs.
class Thing
    attr_reader :name
    def initialize(name, brief_text, world_text = nil, detail_text = nil)
        @name = name
        @brief_text = brief_text
        @world_text = if world_text.nil? then @brief_text else world_text end
        @detail_text = if detail_text.nil? then @world_text else detail_text end
    end

    def describe(context)
        case context
        when :brief then @brief_text
        when :world then @world_text
        when :detail then @detail_text
        else @name
        end
    end
end

# BASE: Monster
# A denizen of the world the player inhabits. Has an inventory, attributes,
# supports describing for :combat, and can attack() and take attribute deltas.
class Monster < Thing
    attr_reader :name, :inventory
    def initialize(name, world_text, attr)
        super(name, name, world_text)
        @inventory = []
        @attributes = attr
    end

    def add_item(item) @inventory += item end

    def print_portrait(indent="    ") end # No portrait unless you subclass it
    def pretty_print(text, show_attr = false)
        print $/, $/
        print_portrait
        Game.pretty_print([text], @name)
        if (show_attr)
            # Assume we have few enough attributes to fit on one line
            cell_width = (Game::ParagraphWidth - 2) / @attributes.size
            @attributes.keys.sort.each do |attr|
                cell_preamble = "| "
                cell_val = attr + ": " + @attributes[attr].to_s
                padding = (cell_width - cell_preamble.length - cell_val.length)
                print cell_preamble, " " * (padding/2), cell_val, " " * (padding - padding/2)
            end
            print " |", $/
            print "+", "-" * (Game::ParagraphWidth - 2), "+", $/
        end
        nil
    end

    def describe(context)
        case context
        when :brief then @name
        when :world then @world_text
        when :detail, :combat then pretty_print(@detail_text)
        else @name
        end
    end

    def get_attribute(attr) @attributes[attr] end
    def delta_attr(deltas = {})
        deltas.each do |attr, delta|
            if @attributes.has_key? attr
                @attributes[attr] += delta
                print "The ", @name, "'s ", attr, " goes ", if delta > 0 then "up" else "down" end, " by ", delta, ".", $/
            end
        end
    end

    def attack(other)
        atk = if @attributes.has_key? "ap" then -@attributes["ap"] else -1 end
        other.delta_attr({ "hp" => atk })
        other.describe(:combat)
    end
end

# MONSTER: Player
# A special kind of monster that thinks it's the center of the universe.
# Subclassed so that we can print correct-sounding messages on various events.
class Player < Monster
    attr_accessor :name, :inventory
    def initialize()
        super("???", "It's you.", { "hp" => 10 })
    end

    def delta_attr(deltas = {})
        deltas.each do |attr, delta|
            if (@attributes.has_key? attr)
                @attributes[attr] += delta
                print "Your ", attr, " goes "
                if delta > 0 then print "up" else print "down" end
                print " by ", delta, ".", $/
            end
        end
    end
    def print_portrait() end # No portrait of player unless you subclass it
end

# BASE: Item
# A thing with a use.
class Item < Thing
    def initialize(name, brief_text, detail_text = nil, world_text = nil)
        super(name, brief_text, world_text, detail_text)
    end

    def use(args = [])
        print "The ", @name, " doesn't seem to have a use.", $/
    end
end

# BASE: Location
# A place in the world. Can have 'doors' that lead to other locations (they 
# don't have to actually be doors, they just represent some kind of area 
# transition.)
# Note that the target of a door may either be another instance of a 
# Location object, the same Location object, or a string to print when the 
# player attempts to use the door.
class Location
    attr_reader :name, :desc, :doors, :things
    def initialize(name, desc)
        @name = name
        @desc = desc
        @doors = {}
        @things = {}
    end

    def follow_door(name)
        ret = nil
        if (@doors[name].is_a? String)
            puts @doors[name]
            ret = self
        else
            ret = @doors[name]
            ret.pretty_print
        end
        return ret
    end

    def pretty_print
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

# BASE: Action
# A verb you can do(). Used by the parser to figure out what should happen when
# the player says something.
class Action
    attr_reader :desc
    def initialize() @desc = "Default action description, please override." end
    def do(args = [])
        puts "No one told me how to ", @class.name, "!"
    end
end

# ACTION: Help
# Used to print out informational text to aid the player.
class Help < Action
    def initialize() @desc = "Show helpful information." end
    def do(args = [])
        if (args.length == 0)
            Game.pretty_print(["Enter commands of the form <verb> <object>. For example, to walk between areas, use 'go north'.", 
                               "Available commands: "] + Game.actions.keys.map{|cmd| " - " + cmd}, 
                               "General help")
        else
            cmd = args[0].downcase
            if (Game.actions.key? cmd)
                Game.pretty_print [Game.actions[cmd].desc], Game.actions[cmd].class.to_s
            else
                puts "No command called ", cmd, "."
            end
        end
    end
end

# ACTION: Go
# Navigates to another Location via one of the doors in the current location.
class Go < Action
    def initialize() @desc = "Move to a nearby location." end
    def do(args = [])
        if args.length < 1
            puts "Go where?"
            return
        end
        if (args[0] == 'n') then args[0] = 'north' end
        if (args[0] == 's') then args[0] = 'south' end
        if (args[0] == 'e') then args[0] = 'east' end
        if (args[0] == 'w') then args[0] = 'west' end
        if Game.location.doors.has_key?(args[0])
            Game.location = Game.location.follow_door(args[0])
        else 
            print "You can't go ", args[0], ".", $/
        end
    end
end

# ACTION: Examine
# Prints out more detailed information about an item in the current Location
# or in the player's inventory
class Examine < Action
    def initialize() @desc = "Examine a nearby object or something in your inventory." end
    def do(args = [])
        if (args.length < 1)
            puts "Examine what?"
        end
        if (args[0] == "self")
            Game.player.print_portrait
        elsif Game.location.things.has_key?(args[0])
            Game.pretty_print Game.location.things[args[0]].describe(:detail), args[0]
        else
            found = false
            Game.player.inventory.each do |item|
                if item.name == args[0]
                    found = true
                    Game.pretty_print item.describe(:detail), args[0]
                    break
                end
            end
            if (not found)
                print "Nothing around that I would call ", args[0], $/
            end
        end
    end
end

# ACTION: attack
# Does the appropriate thing when the player wants to attack something.
# If it's a monster, runs the attack sequence.
class Attack < Action
    def initialize() @desc = "Attack something nearby." end
    def do(args = [])
        if (args.length < 1)
            puts "You flail wildly at the air, to no avail. Perhaps you should specify something to attack."
        elsif Game.location.things.has_key?(args[0])
            thing = Game.location.things[args[0]]
            if thing.is_a? Monster
                Game.player.attack(thing)
                thing.attack(Game.player)
            else
                print "What did the ", thing.name, " ever do to you?", $/
            end
        else
            print "You can't attack that.", $/
        end
    end
end

# ACTION: ShowInventory
# List the items in the player's inventory
class ShowInventory < Action
    def initialize() @desc = "Show the items in your inventory." end
    def do(args = [])
        print "You have "
        if (Game.player.inventory.length == 0) then print "nothing" end
        Game.player.inventory.each_with_index do |thing, index|
            if (index != Game.player.inventory.length - 1)
                print thing.describe(:brief), ", "
            elsif (Game.player.inventory.length > 1)
                print "and ", thing.describe(:brief)
            else
                print thing.describe(:brief)
            end
        end
        print " on your person.", $/
    end
end

class Use < Action
    def initialize() @desc = "Use an item." end
    def do(args = [])
        if (args.length < 0) then print "Use what?", $/ end
        found = false
        Game.player.inventory.each do |item|
            if (item.name == args[0])
                item.use(args[1,-1])
                found = true
            end
        end
        if (not found)
            print "You don't have an item called ", args[0], ".", $/
        end
    end
end

# BASE: Game
# The game class where all the dirty work happens. Subclass this if you want to
# change the way printing, prompting, or parsing work
class Game
    ParagraphWidth = 80
    DefaultActions = { "go" => Go.new, "help" => Help.new, "use" => Use.new,
                       "examine" => Examine.new, "attack" => Attack.new, 
                       "inventory" => ShowInventory.new }
    attr_reader :actions
    attr_reader :player
    attr_accessor :location
    def initialize(location, actions: {}, inventory: [])
        @@instance = self
        @player = Player.new
        @location = location
        @actions = actions.merge(Game::DefaultActions)

        @player.name = Game.prompt "Enter your name:"
        @player.inventory += inventory

        @location.pretty_print
        main_loop
    end

    # Methods to help us treat this as a singleton
    def self.location() return @@instance.location end
    def self.location=(val) @@instance.location = val end
    def self.player() return @@instance.player end
    def self.actions() return @@instance.actions end

    def self.prompt(text="")
        if text != ""
            puts text
        end
        return Readline::readline(@@instance.player.name + " > ", true).strip
    end

    def self.pretty_print(text, label=nil, width=ParagraphWidth)
        if (text.nil?) then return end
        if not text.kind_of?(Array) then text = [text] end

        print $/
        if (label == nil)
            print "+", "-" * (width - 2), "+", $/
        else
            print "+- ", label, " ", "-" * (width - 5 - label.length), "+", $/
        end

        text.each do |p|
            p_remaining = p.dup

            while (p_remaining != "")
                if (p_remaining.length < width - 4)
                    splitind = width - 4
                else
                    splitind = p_remaining.rindex(' ', width - 4)
                    if (splitind.nil?) 
                        splitind = p_remaining.length
                    end
                end
                line = p_remaining.slice!(0..splitind).strip
                print "| ", line, " " * (width - 4 - line.length), " |", $/
            end
        end

        print "+", "-" * (width - 2), "+", $/
    end

    # Read/parse/do loop
    def main_loop()
        until false do
            inp = Game.prompt
            args = inp.split(" ")
            verb = args[0].downcase
            args = args[1..-1]

            if (verb == 'q' or verb == 'quit' or verb == 'exit')
                puts "Quitting...."
                break
            end

            if (@actions.has_key? verb)
                @actions[verb].do(args)
            else
                print "I don't know how to ", verb, "!", $/
            end
        end
    end
end