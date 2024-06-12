# FPTools
##### Email and VoIP management tools built with Flutter
---
###### Problem
Having multiple FastPanel instances to manage multiple SMTP domains is slow and time-consuming. Having multiple Voiso and CommPeak clusters adds to complexity and slows done the workflow.
###### Solution
Application that leverages FastPanel API to manage multiple instances simultaneously to ease creation, removal and management of users. Having option to view Voiso balance and users of multiple clusters helps with that too.

---
#### App features
 - UI, optimised for multiple screen sizes and split-screen work
 - Copying from clipboard for faster user creation:
 ![App feature 1](assets\app_feature_clipboard.png)
 - Pasting to clipboard for easier user management in spreadsheets
 - SOCKS Proxy support for remote work:
 ![App feature 2](assets\app_feature_proxy.png)
 - Option to limit user amount that is shown to operator to optimize loading times:
 ![App feature 3](assets\app_feature_limit_users.png)
 - Data is stored on LAN server and is syncronized between all app operators:
 ![App feature 4](assets\app_feature_updates.png)
 - Randomized passwords for users
 - Logging actions for debugging
 - Easy Voiso and CommPeak cluster managenment
 - Easy FastPanel instance editing and connecting
 - Ability to manage multiple users in the same time
 - Ability to manage multiple emails of the single user
 - Easy creation and management of labels for quick email group selection
 - Automatic renewal of login sessions for all connected FastPanels

 ---
 #### Interface
 ###### Homepage
 ![Home Page](assets\app_section_home.png)
 Displays relevant information (like amount of users, servers, labels or VoIP balances) and allows quicker navigation within the app.

###### Emails page
 ![Emails Page](assets\app_section_emails.png)
Allows for easy search and editing of the emails and users
![User Editing](assets\app_section_emails_edit.png)
This page also allows editing passwords of and removing email accounts.
![User Creation](assets\app_section_emails_create.png)
Operator can also create multiple users on multiple domains in the same time using this app.

###### Servers page
 ![Servers Page](Assets\app_section_servers.png)
This page allows for enabling and disabling FastPanel domains (multiple domains may be present on a single server).
 ![Servers Addition](assets\app_section_servers_add.png)
You can also easily add and verify login data for FastPanel instance.

###### Labels page
 ![Labels Page](assets\app_section_labels.png)
This page allows for easy configuration of labels - groups of domains that help find domains, owned by those groups within the list of domains.
You can reorder labels in the list so they are displayed in any order operator needs them to be.

###### Agents page
 ![Agents Page](assets\app_section_agents.png)
This page shows list of Voiso agents with short summary about them. Voiso API doesn't allow write access on users, so this section is read-only.
 ![Agents View](assets\app_section_agents_view.png)
As stated earlier, it is not possible to create or edit Voiso agents via API, so this page is a read-only info about the agent with intention to make this page into a agent editor later.

###### Clusters page
 ![Clusters Page](assets\app_section_clusters.png)
This page shows Voiso and CP clusters with their respectful balances.
 ![Clusters Add](assets\app_section_clusters_add.png)
You can also add new and edit existing clusters here.

###### CDR page
 ![HLR Page](assets\app_section_cdr.png)
This page shows Call Detail Records, allowing period selection and differentiating between clusters.