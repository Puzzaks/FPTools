# FPTools
##### Email and VoIP management tools built with Flutter
![App Demo Video](assets/app_demo.gif)
---
###### Problem
Having multiple FastPanel instances to manage multiple SMTP domains is slow and time-consuming. Having multiple Voiso and CommPeak clusters adds to complexity and slows down the workflow.
###### Solution
Application that leverages FastPanel API to manage multiple instances simultaneously to ease creation, removal and management of users. Having option to view Voiso balance and users of multiple clusters helps with that too.
> THIS APP IS UNFINISHED! This app is a tool I've made for my job, it is made in a way that it could be adapted to other systems (like other email servers and VoIPs) but it ultimately is a WiP app that will likely be never finished or maintained. Use at your own risk!
---
#### App features
 - UI, optimised for multiple screen sizes and split-screen work
 - Automatic theme change, based on system color and mode
 - Copying from clipboard for faster user creation:
 ![App feature 1](assets/app_feature_clipboard.png)
 - Pasting to clipboard for easier user management in spreadsheets
 - SOCKS Proxy support for remote work:
 ![App feature 2](assets/app_feature_proxy.png)
 - Option to limit user amount that is shown to operator to optimize load times:
 ![App feature 3](assets/app_feature_limit_users.png)
 - Data is stored on LAN server and is synchronized between all app operators:
 ![App feature 4](assets/app_feature_updates.png)
 - Randomized passwords for new accounts
 - Logging actions for debugging
 - Easy Voiso and CommPeak cluster management
 - Easy FastPanel instance editing and connecting
 - Ability to manage multiple users at the same time
 - Ability to manage multiple emails of the single user
 - Easy creation and management of labels for quick email group selection
 - Automatic renewal of login sessions for all connected FastPanels
 - All data is encrypted using AES/CBC encryption

 ---
 #### Interface
 ###### Homepage
 Displays relevant information (like amount of users, servers, labels or VoIP balances) and allows quicker navigation within the app.
 ![Home Page](assets/app_section_home.png)
 
###### Emails page
Allows for easy search and editing of the emails and users
 ![Emails Page](assets/app_section_emails.png)
 
This page also allows editing passwords of and removing email accounts.
![User Editing](assets/app_section_emails_edit.png)

Operator can also create multiple users on multiple domains at the same time using this app.
![User Creation](assets/app_section_emails_create.png)

###### Servers page
This page allows for enabling and disabling FastPanel domains (multiple domains may be present on a single server).
 ![Servers Page](assets/app_section_servers.png)
 
You can also easily add and verify login data for FastPanel instance.
 ![Servers Addition](assets/app_section_servers_add.png)
 
###### Labels page 
This page allows for easy configuration of labels - groups of domains that help find domains, owned by those groups within the list of domains.
You can reorder labels in the list so they are displayed in any order operator needs them to be.
 ![Labels Page](assets/app_section_labels.png)

###### Agents page
This page shows list of Voiso agents with short summary about them. Voiso API doesn't allow write access on users, so this section is read-only.
 ![Agents Page](assets/app_section_agents.png)
 
As stated earlier, it is not possible to create or edit Voiso agents via API, so this page is a read-only info about the agent with intention to make this page into a agent editor later.
 ![Agents View](assets/app_section_agents_view.png)

###### Clusters page
This page shows Voiso and CP clusters with their respectful balances.
 ![Clusters Page](assets/app_section_clusters.png)
 
You can also add new and edit existing clusters here.
 ![Clusters Add](assets/app_section_clusters_add.png)

###### HLR page
You can check number availability/validity using CommPeak and [REDACTED] API.
 ![HLR Page](assets/app_section_hlr.png)
 
###### CDR page
This page shows Call Detail Records, allowing period selection and differentiating between clusters.
 ![CDR Page](assets/app_section_cdr.png)
