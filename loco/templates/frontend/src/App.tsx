import {Admin,Resource,ListGuesser,EditGuesser,ShowGuesser,} from "react-admin";
import { PostList, PostEdit, PostCreate } from "./posts";
import { UserList } from "./users";
import { Layout } from "./Layout";
import { authProvider } from "./authProvider";
import PostIcon from "@mui/icons-material/Book";
import UserIcon from "@mui/icons-material/Group";

export const App = () => (
  <Admin layout={Layout} authProvider={authProvider}>
            {/* <Resource 
            name="posts"
            list={PostList}
            edit={PostEdit}
            create={PostCreate}
            icon={PostIcon}
        />
        <Resource
            name="users"
            list={UserList}
            show={ShowGuesser}
            icon={UserIcon}
        /> */}

  </Admin>
);
