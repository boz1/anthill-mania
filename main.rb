require_relative('Engine')

def main()
	system "clear"
	#Initialize the engine object with desired  grid size and number of anthills
	engine = Engine.new(15,4)
	#Runs the program
	engine.work
end

main













