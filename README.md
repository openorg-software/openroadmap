# OpenRoadmap - Open Source Product Roadmap Planning

## About

## Features

| Name | Description | Status |
| -- | -- | -- |
| Manage Roadmap | Change name of roadmap, sprint length, story points per sprint | Done |
| Add users to roadmap | Create user tags to be assigned to user stories | Done |
| Manage Releases | Add/Remove releases, change name, start date, target date | Done |
| Calculate Release Data | Calculate Story Points per release, calculate end date based on story points in release, show story point difference to target date| Done | 
| Manage User Stories | Add/Remove user stories, change name, description, story points | Done |
| Discuss User Stories |  Add/Remove discussions for each user story to track changes | Done |
| Assign priority to user stories | Add changeable priority to user stories to highlight very important stories | Done  | 
| Assign users to user stories | Add/Remove user tags for each user story | Done |
| Save & Open | Save roadmap to JSON and load it | Done |
| PlantUML Export | Export to PlantUML Gantt Chart  | Done |
| PlantUML Export | Gantt Chart Styling per Roadmap | Done |
| PlantUML Export | Add Milestones per Release |  |
| Jira Export | Export roadmap to Jira | |
| GitLab Export | Export roadmap to GitLab Issues | |
| Gitea Export | Export roadmap to Gitea Issues | |
| UI: Dark mode | Obligatory dark mode | Done |
| UI: Colored users | Allow assigning colors to users | Done |
| UI: Searchable releases | Search for terms in user stories, assigned users and discussion per release | |
| Web deployment | Make deployable as web application with user login (OAuth2.0) and database backend | |
| OpenRQM integration | Link user stories with requirements in OpenRQM | |

## How to build

```bash
flutter pub get
flutter build <desktop platform>
```

## License

SPDX-License-Identifier: GPL-2.0-only

## Copyright

Copyright (C) 2022 - Benjamin Schilling

Based on kanban_test by [cristianvasquez](https://gist.github.com/cristianvasquez)