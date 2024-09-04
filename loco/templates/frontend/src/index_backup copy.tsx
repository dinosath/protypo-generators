import React from "react";
import ReactDOM from "react-dom/client";
import { App } from "./App";

import { Admin, Resource, ShowGuesser } from "react-admin";
import { dataProvider } from './dataProvider';
import { UserList } from "./users";
import { PostList, PostEdit, PostCreate } from "./posts";
import PostIcon from "@mui/icons-material/Book";
import UserIcon from "@mui/icons-material/Group";
import { Dashboard } from "./Dashboard";


ReactDOM.createRoot(document.getElementById("root")!).render(
  <Admin dataProvider={dataProvider} dashboard={Dashboard}>
      <Resource name="posts" list={PostList} edit={PostEdit} create={PostCreate} icon={PostIcon}/>
      <Resource name="users" list={UserList} show={ShowGuesser} icon={UserIcon}/>
  </Admin>
);
