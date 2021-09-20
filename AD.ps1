
$dominioLDAP="DC=beek,DC=local" # Varia segun el dominio

# Crear Unidades Organizativas
function CreateOU
{
   $NombreOU = Read-Host "Introduzca nombre de la unidad organizativa"
   $rutaOU = ("OU="+$NombreOU+","+$dominioLDAP)
   if ([adsi]::Exists(("LDAP://" + $rutaOU))) 
   {
      write-host ("La Unidad Organizativa " + $NombreOU + " ya existe.") -ForegroundColor Red
   } 
   else
   {
      write-host ("Creando la OU "+$NombreOU+","+$dominioLDAP) -ForegroundColor Green
      new-ADOrganizationalUnit -DisplayName $NombreOU -Name $NombreOU -path $dominioLDAP
   }
}

# Crear grupo de seguridad
function CreateSecuritygroup
{
   $NombreOU = Read-Host "Introduzca OU"
   $Groupname = Read-Host "Introduzca nombre del grupo de seguridad ("OU:""$NombreOU ")"
   $rutaOU = ("OU="+$NombreOU+","+$dominioLDAP)
   if (Get-ADGroup -Filter {SamAccountName -eq $Groupname})
   {
     write-host ("El grupo de seguridad ", $Groupname, " ya existe.") -ForegroundColor Red
   }
   else
   {
     New-ADGroup -DisplayName $Groupname -Name $Groupname -GroupScope DomainLocal -GroupCategory Security -Path $rutaOU
   }
}

# Eliminar unidad organizativa
function deleteOU
{
    $NombreOU = Read-Host "Introduzca OU que desea eliminar" # La OU tiene que estar sin objetos dentro sino dará error 
    Get-ADOrganizationalUnit -Filter {Name -eq $NombreOU} | Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion:$false 
    Get-ADOrganizationalUnit -Filter {Name -eq $NombreOU} | Remove-ADOrganizationalUnit -confirm:$false
}

# Esto sirve para validar la disponibilidad de nombres de usuarios
function CheckUser
{ 
   $NombreLogon = Read-Host "Introduzca usuario: " # Ejemplo: jmsolanes

   if (Get-ADUser -Filter {SamAccountName -eq $NombreLogon})
   {
     write-host ("La cuenta de usuario " + $NombreLogon + " ya existe.") -ForegroundColor Red
   }
   else
   {
    Write-Host ("No existe" + $NombreLogon) 
   }
}

# Sabiendo el nombre del usuario podriamos borrarlo sin problemas
function DeleteUser {
    $NombreUsuario = Read-Host "Introduzca nombre del usuario que quiere borrar"
    get-aduser -filter {SamAccountName -eq "$NombreUsuario"} | Remove-ADUser -Confirm:$false

}

function ShowBanner {
    Write-Host ""
    Write-Host "     _     ____   _   _   ____ "
    Write-Host "    / \   |  _ \ | | | | / ___|"
    Write-Host "   / _ \  | | | || | | || |  _ "
    Write-Host "  / ___ \ | |_| || |_| || |_| |"
    Write-Host " /_/   \_\|____/  \___/  \____|"
    Write-Host ""                                             
    Write-Host " By B3nj1,Erik451 - @bruttesei @Erik451"
    write-host " Administrar Usuarios y grupos"
    }                                

ShowBanner
Write-Host "
1 - Crear unidad organizativa
2 - Crear Grupo de seguridad
3 - Eliminar Unidad organizativa
4 - Validad Usuario
5 - Eliminar Usuario
"

$option = Read-Host "Introduzca una opcion"
switch ($option) {
1 {CreateOU}
2 {CreateSecuritygroup}
3 {deleteOU}
4 {CheckUser}
5 {DeleteUser}
default{"No Match found"}
}
