/*
	This class handles connecting and CRUD commands for mongodb.
	This module has a modular design using polymorphism.
*/
module DatabaseHandler;

import std.stdio;
import vibe.d;
import std.digest.md;

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
	string salt;
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
			auto md5 = new MD5Digest ();
			ubyte[] hash = md5.digest( getSalt() ~ new_password );
			employee.password = hash.to!string();	
		}

		string getPassword ()
		{
			return employee.password;
		}

		void setSalt ()
		{
			employee.salt = genRandomSalt().to!string();
		}

		string getSalt ()
		{
			return employee.salt;
		}

		dchar[64] genRandomSalt ()
		{
			import std.algorithm : fill;
			import std.ascii : letters, digits;
			import std.conv : to;
			import std.random : randomCover, rndGen;
			import std.range : chain;

			auto asciiLetters = to!(dchar[])(letters);
			auto asciiDigits = to!(dchar[])(digits);

			dchar[64] salt;
			fill(salt[], randomCover(chain(asciiLetters, asciiDigits), rndGen));
			return salt;
		}

		unittest
		{
			// Checks constructures
			EmployeeHandler databaseHandler = new EmployeeHandler ( "127.0.0.1", "test.Employees");
			writeln ( "Successfully connected to database" );

			// Checks setters and getters
			databaseHandler.setUsername ( "TestUsername" );
			assert ( databaseHandler.getUsername () == "TestUsername" );
			writeln ( "Username added: ", databaseHandler.getUsername () );
			
			databaseHandler.setName ( "Test Name" );
			assert ( databaseHandler.getName () == "Test Name" );
			writeln ( "Name added: ", databaseHandler.getName () );
			
			databaseHandler.setEmail ( "TestEmail@test.com" );
			assert ( databaseHandler.getEmail () == "TestEmail@test.com" );
			writeln ( "Email added: ", databaseHandler.getEmail () );

			databaseHandler.setSalt();
			writeln( "Setting salt: ", databaseHandler.getSalt () );
			
			auto md5 = new MD5Digest();
			databaseHandler.setPassword ( "TestPassword" );
			assert 
			( 
			 	databaseHandler.getPassword () == 
				to!string
				( 
				 	md5.digest
					( 
						databaseHandler.getSalt() ~"TestPassword" 
					) 
				) 
			);
			writeln ( "Password added: ", databaseHandler.getPassword () );

			// Checks creating data
			assert ( databaseHandler.createData() );
			writeln ( "Created user" );

			// Checks updating data
			databaseHandler.setEmail ( "newemail@gmail.com" );
			assert ( databaseHandler.getEmail () == "newemail@gmail.com" );
			assert ( databaseHandler.updateData( "TestUsername" ) );
			writeln ( "Updated user" );

			// Checks deleting data
		//	assert ( databaseHandler.deleteData( "TestUsername"));
			writeln ( "Delete user" );
		}
}
