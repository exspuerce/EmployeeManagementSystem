/*
	This class handles connecting and CRUD commands for mongodb.
	This module has a modular design using polymorphism.
*/
module DatabaseHandler;

import vibe.d;

abstract class DatabaseHandler
{
	private:
			MongoClient client;

	public:
			this ( string ip_address )
			{
				try
				{
					client = connectMongoDB ( ip_address );
			
				} 
				catch ( Exception e )
				{
					writeln ( e );
				}
			}

			abstract bool createData ();
			abstract MongoCursor! ( Bson, User, typeof ( null ) ) readData ();
			abstract bool updateData ();
			abstract bool deleteData ();
}


