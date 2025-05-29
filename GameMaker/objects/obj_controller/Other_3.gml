#region X.1 Destroy Selection List
if (ds_exists(global.selected_pops_list, ds_type_list)) {
    ds_list_destroy(global.selected_pops_list);
}
#endregion