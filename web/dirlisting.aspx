<%@ Page Language="c#" enableSessionState="true" %>
<%@ Import Namespace="Mvolo.DirectoryListing" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Web.SessionState" %>
<%@ Import Namespace="System.Security" %>
<%@ Import Namespace="System.Security.Permissions" %>
<%@ Import Namespace="System.Security.AccessControl" %> 

 

<script runat="server">
public static class SortStore { 
  public static string sortBy = "name";
  public static string path = "/";
}


public class DirSorterByName : IComparer<DirectoryListingEntry>   
{  
  public int Compare(DirectoryListingEntry x, DirectoryListingEntry y)   
  {   
    return (x.FileSystemInfo is FileInfo).ToString().CompareTo((y.FileSystemInfo is FileInfo).ToString())*4+x.Filename.CompareTo(y.Filename);
  }   
} 
public class DirSorterByNameReverse : IComparer<DirectoryListingEntry>   
{  
  public int Compare(DirectoryListingEntry y, DirectoryListingEntry x)   
  {   
    return (y.FileSystemInfo is FileInfo).ToString().CompareTo((x.FileSystemInfo is FileInfo).ToString())*4+x.Filename.CompareTo(y.Filename);
  }   
} 



public class DirSorterByType : IComparer<DirectoryListingEntry>   
{  
  public int Compare(DirectoryListingEntry x, DirectoryListingEntry y)   
  {   
    return (x.FileSystemInfo is FileInfo).ToString().CompareTo((y.FileSystemInfo is FileInfo).ToString())*4+GetFileTypeString(x.FileSystemInfo).CompareTo(GetFileTypeString(y.FileSystemInfo))*2+x.Filename.CompareTo(y.Filename);
  }   
} 
public class DirSorterByTypeReverse : IComparer<DirectoryListingEntry>   
{  
  public int Compare(DirectoryListingEntry y, DirectoryListingEntry x)   
  {   
    return (y.FileSystemInfo is FileInfo).ToString().CompareTo((x.FileSystemInfo is FileInfo).ToString())*4+GetFileTypeString(x.FileSystemInfo).CompareTo(GetFileTypeString(y.FileSystemInfo))*2+x.Filename.CompareTo(y.Filename);
  }   
} 

public static bool CheckFolderPermissions(string directoryPath, FileSystemRights accessType)  
{  
  bool hasAccess = true;  
  try 
  {  
    AuthorizationRuleCollection collection = Directory.  
      GetAccessControl(directoryPath)  
      .GetAccessRules(true, true, typeof(System.Security.Principal.NTAccount));  
    foreach (FileSystemAccessRule rule in collection)  
    {  
      if ((rule.FileSystemRights & accessType) > 0)   
      {  
        return hasAccess;  
      }                      
    }  
  }              
  catch (Exception ex)  
  {  
    hasAccess = false;                  
  }  
  return hasAccess;  
} 


void Page_Load()
{
    String path = null;
    String parentPath = null;
    String sortBy = SortStore.sortBy;
    int count = 0;
    if (!String.IsNullOrEmpty (Request.QueryString["sortby"]) ) {
      sortBy = Request.QueryString["sortby"];
    }
    
    //
    // Databind to the directory listing
    //
    DirectoryListingEntryCollection listing = 
        Context.Items[DirectoryListingModule.DirectoryListingContextKey] as DirectoryListingEntryCollection;
    
    if (listing == null)
    {
        throw new Exception("This page cannot be used without the DirectoryListing module");
    }




// Find the hidden entries
    ArrayList hidden = new ArrayList();
    foreach ( DirectoryListingEntry entry in listing)
    {
      if ((entry.FileSystemInfo.Attributes & FileAttributes.Hidden) == FileAttributes.Hidden)
// !(CheckFolderPermissions(entry.FileSystemInfo.FullName, System.Security.AccessControl.FileSystemRights.ReadData)) || 
      {
        hidden.Add(entry);
      }
    }

// Remove the hidden entries
    foreach ( DirectoryListingEntry hiddenEntry in hidden)
    {
      listing.Remove(hiddenEntry);
    }








    //
    // Handle sorting
    //
    if (!String.IsNullOrEmpty(sortBy))
    {
        if (sortBy.Equals("name"))
        {
            listing.Sort(new DirSorterByName() );
        }
        else if (sortBy.Equals("namerev"))
        {
            listing.Sort(new DirSorterByNameReverse() );
        }            
        else if (sortBy.Equals("date"))
        {
            listing.Sort(DirectoryListingEntry.CompareDatesModified);        
        }
        else if (sortBy.Equals("daterev"))
        {
            listing.Sort(DirectoryListingEntry.CompareDatesModifiedReverse);        
        }
        else if (sortBy.Equals("size"))
        {
            listing.Sort(DirectoryListingEntry.CompareFileSizes);
        }
        else if (sortBy.Equals("sizerev"))
        {
            listing.Sort(DirectoryListingEntry.CompareFileSizesReverse);
        }
        else if (sortBy.Equals("type"))
        {
            listing.Sort(new DirSorterByType() );
        }
        else if (sortBy.Equals("typerev"))
        {
            listing.Sort(new DirSorterByTypeReverse() );
        }

        else {
          sortBy="name";
          listing.Sort(DirectoryListingEntry.CompareFileNames);
        }
    }
    else {
      sortBy="name";
      listing.Sort(DirectoryListingEntry.CompareFileNames);
    }

    SortStore.sortBy = sortBy;


    DirectoryListing.DataSource = listing;
    DirectoryListing.DataBind();
        
    //
    //  Prepare the file counter label
    //
//    FileCount.Text = listing.Count + " items.";

    //
    //
    //  Parepare the parent path label


    SortStore.path = "";
    path = VirtualPathUtility.AppendTrailingSlash(Context.Request.Path).ToString();
    String [] dirs = path.Split(new Char [] {'/'}); 
    int dirPointer = dirs.Length-2;
    if(!path.Equals("/") && !String.IsNullOrEmpty(path)) do {
 



      if (CheckFolderPermissions(System.Web.HttpContext.Current.Server.MapPath(path), System.Security.AccessControl.FileSystemRights.ReadData)) {


      SortStore.path = "<a href=\"" + path + "?sortby="+SortStore.sortBy + "\">" + dirs[ dirPointer] + "/</a>" + SortStore.path;

      }
      else
      {
        SortStore.path = dirs[ dirPointer] + "/" + SortStore.path;
      }

      path = VirtualPathUtility.AppendTrailingSlash(VirtualPathUtility.Combine(path, ".."));
      dirPointer--;
    } while (!path.Equals("/") && !String.IsNullOrEmpty(path) && dirPointer>=0); // 
      
    SortStore.path = "<a href=\"/?sortby="+SortStore.sortBy + "\">Root/</a>" + SortStore.path;


}

String GetFileOpenNewWindow(FileSystemInfo info)
{
    if (info is FileInfo)
    {
        return " target=\"\" ";
    }
    else
    {
        return String.Empty;
    }
}

String GetFileSort(FileSystemInfo info)
{
    if (info is DirectoryInfo)
    {
        return "?sortby="+SortStore.sortBy;
    }
    else
    {
        return String.Empty;
    }
}



public static String GetFileTypeString(FileSystemInfo info)
{
    if (info is FileInfo)
    {
      String Ext = info.Extension.ToString();
      Microsoft.Win32.RegistryKey rk = Microsoft.Win32.Registry.ClassesRoot.OpenSubKey(Ext); 
      if (rk != null && rk.GetValue("") != null)  {
        rk = Microsoft.Win32.Registry.ClassesRoot.OpenSubKey(rk.GetValue("").ToString()); 
        if (rk != null && rk.GetValue("") != null)  {
          return rk.GetValue("").ToString();
        }
        else {
          if(Ext.Length>1){ 
            return Ext.Substring(1, Ext.Length-1).ToUpper() + "-fil";
          } 
          else return "Fil";
        }
      }
      else {
        if(Ext.Length>1){ 
          return Ext.Substring(1, Ext.Length-1).ToUpper() + "-fil";
        }
        else return "Fil";
      }
    }
    else
    {
      if (info is DirectoryInfo)
        return "Filmapp";
      else
        return String.Empty;    
    }
}



String GetFileSizeString(FileSystemInfo info)
{
    if (info is FileInfo)
    {
        return String.Format("{0:#,0} kB", ((int)(((FileInfo)info).Length * 10 / (double)1024) / (double)10));
    }
    else
    {
        return String.Empty;
    }
}

String GetFileDateString(FileSystemInfo info)
{
  if (info is FileInfo)
  {
    return String.Format("{0}", (DateTime)(((FileInfo)info).LastWriteTime));
  }
  else
  {
    return String.Empty;
  }
}

String GetTableHeader()
{
  String hNamn = "<a href=\"?sortby=name\">Name</a>";
  String hSize = "<a href=\"?sortby=size\">Size</a>";
  String hTyp = "<a href=\"?sortby=type\">Type</a>";
  String hDate = "<a href=\"?sortby=date\">Date</a>";

  if(SortStore.sortBy.Equals("name")) {
    hNamn = "<a href=\"?sortby=namerev\">Name &#x25B2; </a>";
  }
  else if(SortStore.sortBy.Equals("namerev")) {
    hNamn = "<a href=\"?sortby=name\">Name &#x25BC; </a>";
  }
  else if(SortStore.sortBy.Equals("size")) {
    hSize = "<a href=\"?sortby=sizerev\">Storlek &#x25B2;</a>";
  }
  else if(SortStore.sortBy.Equals("sizerev")) {
    hSize = "<a href=\"?sortby=size\">Storlek &#x25BC;</a>";
  }
  else if(SortStore.sortBy.Equals("type")) {
    hTyp = "<a href=\"?sortby=typerev\">Typ &#x25B2; </a>";
  }
  else if(SortStore.sortBy.Equals("typerev")) {
    hTyp = "<a href=\"?sortby=type\">Typ &#x25BC; </a>";
  }
  else if(SortStore.sortBy.Equals("date")) {
    hDate = "<a href=\"?sortby=daterev\">Senast ändrad &#x25B2; </a>";
  }
  else if(SortStore.sortBy.Equals("daterev")) {
    hDate = "<a href=\"?sortby=date\">Senast ändrad &#x25BC; </a>";
  }
  return hNamn + "</td><td align=\"right\">"+hSize+"</td><td>"+hTyp+"</td><td>"+hDate;
}


</script>
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Directory contents of <%= Context.Request.Path %></title>
        <style type="text/css">
            body { text-decoration: none; color:#606060 }
            a { text-decoration: none; color:#606060 }
            a:link { text-decoration: none; color:#606060 } 
            a:hover { text-decoration: none; color:#606060 } 
            a:active { text-decoration: none; color:#606060 } 
            a:visited { text-decoration: none; color:#606060 }
            a.fil { text-decoration: none; color:#000000 }
            a.fil:link { text-decoration: none; color:#000000 } 
            a.fil:hover { text-decoration: none; color:#000000 } 
            a.fil:active { text-decoration: none; color:#000000 } 
            a.fil:visited { text-decoration: none; color:#000000 }

            p {font-family: verdana; font-size: 9pt; }
            h2 {font-family: verdana; font-size: 13pt; }
            td {font-family: verdana; font-size: 9pt; } 
            img {border:0;height:11pt;padding-right:20px}  
            table, td {padding-right:9pt}                        
        </style>
    </head>
    <body>
        <form runat="server">
        <h2><%=SortStore.path %></h2>
            <hr />
            <table>
           
            <asp:DataList id="DirectoryListing" RepeatLayout="Table" runat="server">
                <HeaderTemplate>
                 <%# GetTableHeader() %>
                </HeaderTemplate>
                <ItemTemplate>
                    
                    <a class="fil" href="<%# ((DirectoryListingEntry)Container.DataItem).VirtualPath %><%# GetFileSort(((DirectoryListingEntry)Container.DataItem).FileSystemInfo) %>" <%# GetFileOpenNewWindow(((DirectoryListingEntry)Container.DataItem).FileSystemInfo) %>>
                      <img alt="" src="<%=HttpRuntime.AppDomainAppVirtualPath %>geticon.axd?file=<%# (((DirectoryListingEntry)Container.DataItem).FileSystemInfo is DirectoryInfo) ? ".folder" : String.IsNullOrEmpty(Path.GetExtension(((DirectoryListingEntry)Container.DataItem).Path)) ? ".*" : Path.GetExtension(((DirectoryListingEntry)Container.DataItem).Path) %>" /> 
                      <%# ((DirectoryListingEntry)Container.DataItem).Filename %>
                    </a>
</td><td valign="bottom" align="right">
                    &nbsp<%# GetFileSizeString(((DirectoryListingEntry)Container.DataItem).FileSystemInfo) %>
</td>
<td valign="bottom" align="Left">
                    &nbsp<%# GetFileTypeString(((DirectoryListingEntry)Container.DataItem).FileSystemInfo) %>
</td>
<td valign="bottom" align="Left">
                    &nbsp<%# GetFileDateString(((DirectoryListingEntry)Container.DataItem).FileSystemInfo) %>

                </ItemTemplate>
            </asp:DataList>
            </table>                

        </form>
    </body>
</html>