# internshipDatabase

An exploration of persistent storage in R Shiny via a SQLite database. 

### Inspiration: 

Last semester I had a hard time managing my internship applications, and these troubles discouraged me from applying to internships at all (not good). I realised that maybe if I created my own mini application to address this, I would actually apply to internships (as I should be doing) and stay on top of the status of each. 

### The app: 

There are four tabs: 

- **Create entries**: enter information about each internship you've applied for

![image](https://github.com/jasminex21/internshipDatabase/assets/109494334/0da88ce1-bcb2-4c23-8dab-ab53c0095c6b)

- **Track Updates**: track the internships you've heard back from

![image](https://github.com/jasminex21/internshipDatabase/assets/109494334/55e53de5-ba6e-4fb8-9067-60663a888e1e)

- **Filter Entries**: use SQL commands to filter or alter tables (in case you make a mistake when entering information about an application). Ideally not something I will keep in updated versions of the app; just here temporarily for convenience.

![image](https://github.com/jasminex21/internshipDatabase/assets/109494334/6f0c494c-157b-49de-90eb-e04bd14b655f)

- **To Check Out**: record and track internships that you plan to apply to (entries can be removed once they have been addressed)

![image](https://github.com/jasminex21/internshipDatabase/assets/109494334/7169acde-5d76-40cc-9bd0-0b0ba4305d42)

- **Resources**: statistics (that can be filtered by application cycle) and resources to guide you during the application cycle

![image](https://github.com/jasminex21/internshipDatabase/assets/109494334/1846161f-193e-4c40-8882-fda37b1dcb2d)

### TODO:
- Make everything less manual and more editable: 
  - Combine the Create Entries and Track Updates tables - it'd be useful if you didn't have to manually add an ID in. I think it'd be cool to make it so that there is a dropdown where you can select, say, "rejected" or "first round interview"
  - Make entries actually editable after they are confirmed, because at the moment I have to delete the entry and redo it if I want to make changes. If I want to add more notes for example, I want to actually be able to edit it directly.
    - Consider doing this using the `rhandsontable` package - would require changing a good amount of things (https://jrowen.github.io/rhandsontable/#Shiny)
    - There is also an `editable = TRUE` parameter in `DT::datatable`; if this works it'd be great but so far I have not seen success. 
 - Figure out how to make Enter count as a line break. For now, I've had to use `<br/>` which is obviously not ideal.
 - Ultimate aim is to be able to actually publish this as an app that more people can use. This would require user authentication for sure. I will also have to figure out how to create/initialize a new database for each new user.
 - Remove the Edit Entries tab once datatables are editable. It isn't user-friendly (was only really for me to edit the tables since I couldn't do so directly) and it makes it far too easy to simply delete important info by mistake.
