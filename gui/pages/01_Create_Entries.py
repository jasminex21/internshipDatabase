import streamlit as st

cycles = ["Summer 2023", "Fall 2023", "Summer 2024", "Summer 2025", "Other"]
tags = ["Favorite", "Hopeful", "Long shot", "Remote", "Hybrid"]
statuses = ["Pending", "Interview", "Rejected", "Accepted"]

st.title("Create Entries")

with st.sidebar: 
    with st.form("create_entries_form"):
        cycle = st.selectbox("Application cycle", 
                             options=cycles)
        status = st.selectbox("Status", 
                              options=statuses)
        date = st.date_input("Date applied", 
                             value="today", 
                             format="MM/DD/YYYY")
        position_name = st.text_input("Position", 
                                      placeholder="e.g. Data Science Intern")
        company_name = st.text_input("Company", 
                                     placeholder="e.g. Google")
        role_tags = st.multiselect("Tags", 
                                       options=tags)
        description = st.text_area("Role description (optional)", 
                                   placeholder="A brief description of your role")
        link = st.text_input("Link", 
                             placeholder="Link to position")
        submit_btn = st.form_submit_button("Submit")

if submit_btn: 
    st.write("Form submitted")
