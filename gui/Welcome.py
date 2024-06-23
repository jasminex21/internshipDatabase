import streamlit as st
import streamlit_authenticator as stauth
import yaml
import smtplib
import sqlite3
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

authenticator.login()

if st.session_state["authentication_status"]:
    st.subheader(f'Welcome {st.session_state["name"]}!', divider='green')
    authenticator.logout(location="sidebar", key="logout_button")
elif st.session_state["authentication_status"] is False:
    st.error('Username or password is incorrect')
elif st.session_state["authentication_status"] is None:
    st.warning('Please enter your username and password')