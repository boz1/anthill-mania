Burak Fidansoy
Burak Oz
CS 342 - Project 4
README


Flow of the program:

1. An 'Engine' object is initialized with size of the grid and number of the anthills.
2. Engine object's 'work' method is called, which is responsible for running the program.
3. The meadow class instance's setNumberOfAnthills and setSize methods are called with the given parameters.
// Since 'Meadow' class is implemented with Singleton, the program guarantees that all the methods will be called on the same meadow
4. After setting the grid size, the setSize method of the meadow instance;
			4.1 First calls the getStrategies method which dynamically creates 4 different strategies based on the strategy types.
			    These strategy types are: Greedy, Aggresive, Constructive, and Balanced
				Each strategy contains 15 items ('warrior', 'forager', 'warrior', etc.)in it.
				These strategies are held in a "@strategies = []" array.
			4.2 After the strategies are set, it calls the createCells method of the meadow instance.
				This method basically created the grid with the desired size and for each cell it instantiates
				a 'Cell' object.
5. After executing itself, createCells method calls the "callBuilderQueen" method. This method creates a 'queen' object.
// The 'Queen' class uses the Builder pattern to create the Anthills on the meadow
6. The queen object created in callBuilderQueen method will configure desired number of anthills by calling itselves addAnthill method
   with configuration options, and then calls the build method to actually build the anthill.
   Example call => "queen.addAnthill(setAnthillPosition, @strategies[i], String.colors[(i*2 + 4) % 16]).build"
			6.1 setAnthillPosition in this call will find a random empty spot for the anthill.
			6.2 the next strategy on "@strategies" array will be assigned to the anthill
			6.3 the color of the anthill will be assigned by using the "colorize" gem of Ruby
			6.4 the build method will return the anthill if it is configured, the returned anthill will be added to the "@anthills = []" array
7. When the builder queen is done, updateCellsWithAnthill will get called. This method will update "@hill" property of the cells with an anthill
8. After all the cells with anthill are updated, engine displays the meadow for the first time.
9. On creation, each anthill object has 3 rooms, one for each, and 5 pieces of food.
10. After the meadow is displayed for the first time, which only has the anthills on it, the engine will call the next turn and display the meadow
    based on the result of it. This cycle will go on until either one anthill or no anhtills are left. If there is a winner, their colors will be displayed
	all over the meadow.
// At the start of each turn, food will be spawned to random locations based on number of anthills in the meadow. (ex. 4 foods will be spawned each turn if there are 4 anthills)
11. The nextTurn method of the meadow is called for each "alive" anthill on each round. After its called for all antills the meadow will be displayed.
    Flow of the nextTurn method is like this;
			11.1 If anthill has at least one foragers, which means its still alive, the method will traverse each ants in that anthill.
			11.2 If the ant is "alive", the method will check the type of the ant.
				11.2.1 If it is a 'builder', and there is enough food, and the number of max ants in an anthill is not exceeded, the builder ant
				       will create a room based on the strategy of the anthill.
				11.2.2 If it is 'forager', it will first move to a new cell, and then check the ants on the cell, fight if necessary, and get food
				       on the cell if there is any. If it manages to escape an opponent 'warrior' ant or collect to a food, it gains xp.
					   If a 'forager' ant has more than 2 xp points, each next food piece it collects will count as double.
					   If it loses the fight with the opponent 'warrior', it dies.
				11.2.3 If the ant type is a 'warrior', it will first move to a new cell, and then it will check the ants on the cell. If there is an ant
				       from a different anthill it will fight with it. If it wins agains a 'forager' it will gain 1 xp. If it wins agains a 'warrior'
 					   it will gain 2 xp, otherwise it dies (a random number produced based on square of a warrior's xp will determine the winner). 
					   If it faces an anthill, and wins, it will gains 5 xp. Also, it will change it's symbol color from white to the anhtills color.
					   //Each ant is represented with a white symbol, and a background color based on their anthill
			11.3 When all ants are executed, anthill' s callRooms method will be called. This method spawns an ant based on the rooms, if there is enough food and enough space
 			     for a new ant(if current ant count < max ant number(equals to the grid size, which is 15). The ant will be spawned with the room's spawnAnt method.
				 The ant type functionality will be added with "Object Runtime Modification" in this method. Each ant willoverride the "execute" method based on its type.
				 The spawned ant will be returned.
			11.4 If the anthill has no foragers, which means its not alive anymore, 'nil' will be assigned to its containing cell's "@hill" attribute.
				 Also, the anthill's @isAlive attribute will be set to 'false'.(This will be used when displaying the meadow)
12. When a turn is completed for all anthills, the meadow will be displayed with the latest updates.
13. Until there is only one anthill left, or all anthills are dead, this cycle will go on.
13. When there is no alive anthill, or only one, the cycle will stop, and the winner's colors, if there is any, will be displayed all over the meadow.
 
Patterns used in the program:

Singleton Pattern:

The Singleton pattern is used in Meadow class in order to ensure that only one Log object will be created. By doing this, we guarantee that
all operations will be made on the meadow. We've implemennted Singleton pattern by using the Singleton module defined in Ruby. The Meadow class instance
is used by 'Meadow.instance' commmand. Some of the methods called on this instance are 'Meadow.instance.nextAnthill', and 'Log.instance.displayMeadow'.

Builder Pattern:

The Builder Pattern is used in Queen class. The queen object created in callBuilderQueen method will "configure" desired number of anthills by calling itselves addAnthill method
with the configuration options, and then calls the "build()" method to actually build the anthill.
Example call => "queen.addAnthill(setAnthillPosition, @strategies[i], String.colors[(i*2 + 4) % 16]).build"

Modified Factory Pattern (Object Runtime Modification):

Since there is a single Ant class, the room will first create a basic ant object, and then it will modify the ant on runtime by using the Object Runtime Modification.
The ant type functionality is added to the ant in this part. 

An example usage:

ant = Ant.new(@anthill) // Create a new Ant Object

class << ant // Ant type functionality is added with Object Runtime Modification
	def setAnt
		@ant_type = "builder"
	end
	def execute(room_type)
		anthill.food -= 1 #builder ant consumes 1 piece of food to create a new room
		room = Room.new(@anthill, room_type) #creates a room based on the room_type (determined by the anthill strategy)
		@alive = false #dies after the room is created
		@anthill.builders_count -= 1
		room
	end
end