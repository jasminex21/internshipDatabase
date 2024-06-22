import streamlit as st
import streamlit_authenticator as stauth
import yaml
import smtplib
from email.mime.text import MIMEText
from yaml.loader import SafeLoader

with open("/home/jasmine/OneDrive - The University of Texas at Austin/Personal Projects/internshipDatabase/gui/credentials.yaml") as file:
    config = yaml.load(file, Loader=SafeLoader)

st.title("Internship Database")

authenticator = stauth.Authenticate(
    config['credentials'],
    config['cookie']['name'],
    config['cookie']['key'],
    config['cookie']['expiry_days'],
    config['pre-authorized']
)

# forgot_pwd_btn = st.button("Forgot password")
authenticator.login()

if st.session_state["authentication_status"]:
    st.subheader(f'Welcome {st.session_state["name"]}!', divider='green')
    authenticator.logout()
elif st.session_state["authentication_status"] is False:
    st.error('Username or password is incorrect')
elif st.session_state["authentication_status"] is None:
    st.warning('Please enter your username and password')

try:
    username_of_forgotten_password, email_of_forgotten_password, new_random_password = authenticator.forgot_password()
    if username_of_forgotten_password:
        st.success('New password to be sent securely')
        # The developer should securely transfer the new password to the user.
        subject = 'New [Random] Password'
        body = f"""
                Hello {username_of_forgotten_password},

                Here is your new password: {new_random_password}

                If you did not request a password reset, please ignore this email.

                """
        # Create the MIMEText object
        msg = MIMEText()
        msg['From'] = "jasminexu@utexas.edu"
        msg['To'] = email_of_forgotten_password
        msg['Subject'] = subject
        msg.attach(MIMEText(body, 'plain'))
    elif username_of_forgotten_password == False:
        st.error('Username not found')
except Exception as e:
    st.error(e)

try:
    email_of_registered_user, username_of_registered_user, name_of_registered_user = authenticator.register_user(pre_authorization=False)
    if email_of_registered_user:
        st.success('User registered successfully')
except Exception as e:
    st.error(e)
