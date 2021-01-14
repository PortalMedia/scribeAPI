db.createUser(
	{
		user: "loop_dev",
		pwd: "loop_dev",
		roles: [
			{ 
				// role: "readWrite",
				role: "dbAdmin",
				db: "loop_dev"
			}
		]
	}
)
