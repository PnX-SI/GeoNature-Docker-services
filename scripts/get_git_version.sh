# args
#  - $1 dir: repertoire du dépôt
#  - $2 preffix: preffixe pour la variable c'env (GN_ ou GN_MODULE_MONITORNING)
#
#  récupère les infos sur
#  - le tags du dépôt
#  - le nom de la branche
#  - la version lu depuis le fichier VERSION
#
#  crée 3 variables d'environnement
#  - ${preffix}_GIT_VERSION
#  - ${preffix}_IS_TAG
#  - ${preffix}_FILE_VERSION


dir=$1
preffix=$2

cur=$(pwd)
cd $dir

GIT_TAG=$(git describe --exact-match --tags $(git log -n1 --pretty='%h'))
GIT_BRANCH=$(git branch --show-current)
FILE_VERSION=$(cat VERSION)
# echo $1 $2 $GIT_BRANCH $GIT_TAG
if [[ ! -z "${GIT_BRANCH}" ]]; then
    assign_git_version="export ${preffix}_GIT_VERSION=${GIT_BRANCH}; export ${preffix}_IS_TAG=false";

elif [[ (! -z "${GIT_TAG}") ]]; then
    assign_git_version="export ${preffix}_GIT_VERSION=${GIT_TAG}; export ${preffix}_IS_TAG=true";

else
    assign_git_version="export ${preffix}_GIT_VERSION=''; export ${preffix}_IS_TAG=''"
fi

eval $assign_git_version

assign_file_version="export ${preffix}_FILE_VERSION=${FILE_VERSION}"
eval $assign_file_version

cd $cur
