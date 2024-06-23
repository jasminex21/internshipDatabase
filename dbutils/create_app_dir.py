import os

def create_app_dir(): 
    """
    Creates internshipDatabase directory in the user's home directory. 
    To be called when a user registers for the first time and grants
    permissions*. 
        * To be implemented

    Returns: 
        new_dir_name [str]: 
            The path to the new directory
    """
    user_home_dir = os.path.expanduser("~")
    new_dir_name = os.path.join(user_home_dir, "internshipDatabase")
    os.makedirs(new_dir_name)
    return new_dir_name