/*
	This class handles connecting and CRUD commands for mongodb.
	This module has a modular design using polymorphism.
*/
module DatabaseHandler;

import std.stdio;
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
		abstract bool updateData ( string identifier );
		abstract bool deleteData ( string identifier );
}

struct Employee
{
	string username;
	string name;
	string email;
	string password;
}

class EmployeeHandler : DatabaseHandler
{
	private:
		MongoCollection employee_collection;
		Employee employee;

	public:
		this ( string ip_address, string collection )
		{
			super ( ip_address );
			try
			{
				employee_collection = client.getCollection(collection);
			}
			catch ( Exception e )
			{
				writeln ( e );
			}
		}

		override bool createData ()
		{
			try
			{
				employee_collection.insert ( employee );
				return true;
			}
			catch ( Exception e )
			{
				writeln( e );
				return false;
			}
		}

		override bool updateData (string identifier)
		{
			try
			{
				employee_collection.update
				(
				 	[ "username" : identifier ],
					[
						"username" 	: getUsername(),
						"name" 		: getName(),
						"email" 	: getEmail(),
						"password" 	: getPassword()
					]
				);
				return true;
			}
			catch ( Exception e )
			{
				writeln ( e );
				return false;
			}	
		}

		override bool deleteData ( string identifier )
		{
			try
			{
				employee_collection.remove ( [ "username" : identifier ] );
				return true;
			} 
			catch ( Exception e ) 
			{
				writeln ( e );
				return false;
			}
		}

		void setUsername ( string new_username )
		{
			employee.username = new_username;
		}

		string getUsername ()
		{
			return employee.username;
		}

		void setName ( string new_name )
		{
			employee.name = new_name;
		}

		string getName ()
		{
			return employee.name;
		}

		void setEmail ( string new_email )
		{
			employee.email = new_email;
		}

		string getEmail ()
		{
			return employee.email;
		}

		void setPassword ( string new_password )
		{
			employee.password = new_password;
		}

		string getPassword ()
		{
			return employee.password;
		}
}
