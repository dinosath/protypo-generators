import { TopToolbar, SelectColumnsButton, FilterButton, CreateButton, ExportButton } from "react-admin";

export const ListActions = () => (
    <TopToolbar>
        <FilterButton />
        <CreateButton />
        <ExportButton />
        <SelectColumnsButton />
    </TopToolbar>
);