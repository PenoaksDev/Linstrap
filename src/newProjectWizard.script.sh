#!/dev/null
# shellcheck shell=bash
#
##############################################################################
##  This software may be modified and distributed under the terms
##  of the MIT license.  See the LICENSE file for details.
##
##  Unless required by applicable law or agreed to in writing,
##  software distributed under the License is distributed on an
##  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
##  KIND, either express or implied.  See the License for the
##  specific language governing permissions and limitations
##  under the License.
##
##  Copyright (c) 2021 Amelia Sara Greene <barelyaprincess@gmail.com>
##  Copyright (c) 2021 Penoaks Publishing LLC <development@penoaks.com>
##
##  Linstrap: Linux OS Bootstrapping and Launcher for UN*X
##############################################################################
#

{
    BUILD_KERNEL=$(no)
    BUILD_INITRD=$(yes)

    ### Initialize Project Metadata ###

    # TODO Put project prompt
    PROJECT_NAME="HoneyPotLinux"

    PROJECT_DIR="${APP_PROJECTS}/${PROJECT_NAME}"

    # TODO Check project directory and determine the status of the project; prompt to override and etc.

    mkdir -vp "${PROJECT_DIR}" 2>/dev/null


    READY_TO_BUILD=$(yes)


    ### Initializing Kernel ###


    if is "${BUILD_KERNEL}" yes; then
        ob_start "Initializing Kernel"

        # shellcheck source=./Projects/HoneyPotLinux/kernel.conf
        . "${PROJECT_DIR}/kernel.conf" 2>/dev/null || echo "kernel.conf does not exist."

        # Kernel Type: [NONE], Use [PREBUILD] (Specified Kernel Binary), Use [HOST], Clone from [GIT]Hub Repository (Vanilla or Linstrap versions), from [TAR] download.
        KERNEL_TYPE="${KERNEL_TYPE:-GIT}"

        KERNEL_DIR=${PROJECT_DIR}/Kernel

        # TODO Create is needed only, git and tar should be the only ones that will need a location to store the kernel source code.
        mkdir -vp "${KERNEL_DIR}" 2>/dev/null

        # PREBUILD - Specify location of each kernel file, i.e., bzImage, VMLinuz, Initrd, Config, System
        KERNEL_PREBUILD_KERNEL="${KERNEL_PREBUILD_KERNEL:-}"
        KERNEL_PREBUILD_INITRD="${KERNEL_PREBUILD_INITRD:-}"
        KERNEL_PREBUILD_SYSTEM="${KERNEL_PREBUILD_SYSTEM:-}" # Optional
        KERNEL_PREBUILD_CONFIG="${KERNEL_PREBUILD_CONFIG:-}" # Optional

        # HOST
        KERNEL_HOST_VERSION="$(uname -r)"
        KERNEL_HOST_KERNEL="${KERNEL_HOST_KERNEL:-}"
        KERNEL_HOST_SYSTEM="${KERNEL_HOST_SYSTEM:-}" # Optional
        KERNEL_HOST_CONFIG="${KERNEL_HOST_CONFIG:-}" # Optional

        # GIT
        KERNEL_GIT_URL="${KERNEL_GIT_URL:-git@github.com:PenoaksDev/Linstrap-Kernel.git}"
        KERNEL_GIT_BRANCH="${KERNEL_GIT_BRANCH:-}"

        # TAR
        KERNEL_TAR_URL="${KERNEL_TAR_URL:-https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.12.6.tar.xz}"

        case "${KERNEL_TYPE,,}" in
            none)
                echo "Kernel is set to 'NONE', this script will automatically exit at the build stage because a kernel is required to continued."; # Warning
                READY_TO_BUILD=$(no)
                ;;
            prebuild)
                echo "Kernel is set to 'PREBUILD'";
                # TODO Implement
                ;;
            host)
                echo "Kernel is set to 'HOST'";

                ## Try to automatically detect the running kernel file, otherwise prompt with a list.
                ## If "/boot" is missing, throw an error and suggest user uses the "PREBUILD" option instead.

                # If var is not set, version does not match, or does not exist.
                if [ -z "${KERNEL_HOST_KERNEL}" ] || [[ "${KERNEL_HOST_KERNEL}" != "*${KERNEL_HOST_VERSION}*" ]] || [ ! -f "${KERNEL_HOST_KERNEL}" ]; then
                    # SYSTEM and CONFIG are not required, so drop them just in case the kernel changes.
                    KERNEL_HOST_SYSTEM=""
                    KERNEL_HOST_CONFIG=""

                    find "/boot" -name "*$(uname -r)*" | while read -r FILE; do
                        case "${FILE}" in
                            *vmlinuz*|*bzimage*)
                                KERNEL_HOST_KERNEL="${FILE}"
                                ;;
                            *system*)
                                KERNEL_HOST_SYSTEM="${FILE}"
                                ;;
                            *config*)
                                KERNEL_HOST_CONFIG="${FILE}"
                                ;;
                        esac
                    done
                fi
                ;;
            git)
                echo "Kernel is set to 'GIT'";

                if [ -d "${KERNEL_DIR}/.git" ] && git -C "${KERNEL_DIR}" remote -v | grep -E "origin.+${KERNEL_GIT_URL}" &>/dev/null; then
                    git -C "${KERNEL_DIR}" pull 2>&1 | prepend "GIT -->"
                else
                    git -C "${KERNEL_DIR}" clone --branch "${KERNEL_GIT_BRANCH}" "${KERNEL_GIT_URL}" 2>&1 | prepend "GIT -->"
                fi
                ;;
            tar)
                echo "Kernel is set to 'TAR'";
                # TODO Implement
                ;;
            *)
                echo "Unreconized Kernel Type: ${KERNEL_TYPE}, quiting..."
                ob_end "FAILURE"
                exit 1
                ;;
        esac

        echo "Saving Kernel Confiration: "
        
        echo -en "#!/dev/null\n# shellcheck shell=bash\n### Kernel Configuration File. Created at $(date) ###\n\n" > "${PROJECT_DIR}/kernel.conf"
        declare -p | grep -E "KERNEL_[A-Z0-9]" | sort | tee -a "${PROJECT_DIR}/kernel.conf" | prepend "CONF -->"

        ob_end "SUCCESS"
    fi


    ### Initializing Initrd ###

    
    if is "${BUILD_INITRD}" yes; then
        ob_start "Initializing Initrd"

        # shellcheck source=./Projects/HoneyPotLinux/initrd.conf
        . "${PROJECT_DIR}/initrd.conf" 2>/dev/null || echo "initrd.conf does not exist."

        # Initrd Type: [CUSTOM], Clone from [GIT]Hub Repository (Vanilla or Linstrap versions).
        INITRD_TYPE="${INITRD_TYPE:-CUSTOM}"

        INITRD_DIR="${PROJECT_DIR}/Initrd"
        mkdir -pv "${INITRD_DIR}" 2>/dev/null

        # CUSTOM
        INITRD_CUSTOM_VERSION_STRING="+%Y-%m-%d %H:%M"
        INITRD_CUSTOM_PACKAGES=""

        # GIT
        INITRD_GIT_URL="${INITRD_GIT_URL:-git@github.com:PenoaksDev/Linstrap-Stencils.git}"
        INITRD_GIT_BRANCH="${INITRD_GIT_BRANCH:-initrd-bleeding}"

        INITRD_BUILT_WITH="${INITRD_BUILT_WITH:-${LINSTRAP_VERSION}}"

        case "${INITRD_TYPE,,}" in
            custom)
                echo "Initrd type is set to 'CUSTOM'";

                # if [ ! -f "${INITRD_DIR}/.version" ] || [ "$(cat "./.version")" != "$(date "${INITRD_CUSTOM_VERSION_STRING}")" ]; then
                    INITRD_BUILT_WITH="${LINSTRAP_VERSION}"

                    echo "Built with Linstrap v${INITRD_BUILT_WITH}" > "${INITRD_DIR}/.version"
                    echo "Created at $(date "${INITRD_CUSTOM_VERSION_STRING}")" >> "${INITRD_DIR}/.version"

                    mkdir -pv "${INITRD_DIR}/bin" "${INITRD_DIR}/lib"

                    function install_deb() {
                        PKG_NAME=${1,,}

                        # Create fake debian package manager files (dpkg)
                        mkdir -pv "${INITRD_DIR}/var/lib/dpkg/"{updates,info}
                        touch "${INITRD_DIR}/var/lib/dpkg/"{status,info}

                        {
                            cd "${APP_CACHE}"
                            apt download "${PKG_NAME}" 2>/dev/null
                            dpkg --root="${INITRD_DIR}" --unpack -- "${APP_CACHE}/${PKG_NAME}"*.deb 2>&1
                        }
                    }

                    install_deb busybox-static
                    install_deb libklibc
                    install_deb klibc-utils

                    chroot "${INITRD_DIR}" /bin/busybox sh -c "for binary in \$(/bin/busybox --list); do [ \"\${binary}\" != \"busybox\" ] && ln -s \"/bin/busybox\" \"/bin/\${binary}\" || true; done" 2>/dev/null

                    # Add bloat files to the "do not pack" list.
                    exec 3>"${INITRD_DIR}/do-not-pack.list"
                    cat "${INITRD_DIR}/var/lib/dpkg/info/"*.list | while read -r ENTRY; do
                        FILE="$(realpath --no-symlinks "${INITRD_DIR}/${ENTRY:1}")"
                        if [[ "${ENTRY}" =~ doc/|man/ ]]; then
                            echo "${FILE:${#INITRD_DIR}}" >&3
                        fi
                        unset FILE
                    done
                    exec 3>&-

                    ## Apply updates from Linstrap Data directory
                    rsync --progress -av "${APP_ROOT}/Data/Initrd/" "${INITRD_DIR}"
                # else
                #    echo "Skipping setting up Initrd, the version is recent."
                # fi
                ;;
            git)
                echo "Initrd type is set to 'GIT'";

                if [ -d "${INITRD_DIR}/.git" ] && git -C "${INITRD_DIR}" remote -v | grep -E "origin.+${INITRD_GIT_URL}" &>/dev/null; then
                    git -C "${INITRD_DIR}" pull 2>&1 | prepend "GIT -->"
                else
                    git -C "${INITRD_DIR}" clone --branch "${INITRD_GIT_BRANCH}" "${INITRD_GIT_URL}" 2>&1 | prepend "GIT -->"
                fi
                ;;
            *)
                echo "Unreconized Initrd Type: ${INITRD_TYPE}, quiting..."
                ob_end "FAILURE"
                exit 1
                ;;
        esac

        echo "Saving Initrd Confiration: "
        
        echo -en "#!/dev/null\n# shellcheck shell=bash\n### Initrd Configuration File. Created at $(date) ###\n\n" > "${PROJECT_DIR}/initrd.conf"
        declare -p | grep -E "INITRD_[A-Z0-9]" | sort | tee -a "${PROJECT_DIR}/initrd.conf" | prepend "CONF -->"

        ob_end "SUCCESS"
    fi


    ### Build Entire Project ###


    if is "${READY_TO_BUILD}"; then
        echo "Preparing to build the entire project."

        PROJECT_OUTPUT_DIR="${PROJECT_DIR}/Output"
        mkdir -vp "${PROJECT_OUTPUT_DIR}" 2>/dev/null   

        ## Build Kernel ##

        if is "${BUILD_KERNEL}" yes; then
            function mk () {
                INSTALL_PATH="${PROJECT_OUTPUT_DIR}" INSTALL_MOD_PATH="${INITRD_DIR}" make -C "${KERNEL_DIR}" -j "${CPU_COUNT}" "$@"
            }

            # Build the Linstrap Kernel and install files in their rightful place.
            ob_start "Building Kernel"

            case "${KERNEL_TYPE,,}" in
                "git")
                    {
                        # TODO Check for dependencies required to build the kernel. Could perhaps create a build chroot for the purpose of doing so.

                        #apt -y install build-essential libncurses-dev libelf-dev
                        #apt -y install git gcc curl make libxml2-utils flex m4
                        #apt -y install openjdk-8-jdk lib32stdc++6 libelf-dev
                        #apt -y install libssl-dev python-enum34 python-mako syslinux-utils

                        mk honeypot_defconfig
                        mk install
                        mk modules_install
                    } | prepend "KERNEL BUILD -->"
                    ;;
                *)
                    echo "Nothing to build."
                    ;;
            esac

            ob_end "SUCCESS"
        fi

        ## Pack Initrd ##

        if is "${BUILD_INITRD}" yes; then
            ob_start "Packing Initrd"

            find "${INITRD_DIR}" | sed -E "s#${INITRD_DIR}/{0,1}##g" | grep -Ev "^(proc|dev|sys)/" | tee -a "${OB_PIPE}" | eval "cd \"${INITRD_DIR}\" && cpio --create -H \"newc\" | gzip -9 >\"${PROJECT_OUTPUT_DIR}/initrd.img-linstrap${LINSTRAP_VERSION}\""

            echo "Finished packing files into \"${PROJECT_OUTPUT_DIR}/initrd.img-linstrap${LINSTRAP_VERSION}\""

            ob_end "SUCCESS"
        fi

cat > "${PROJECT_OUTPUT_DIR}/qemu-start.sh" <<-EOF
#!/bin/bash
echo "Running Linstrap with QEMU"
mknod /tmp/linstrap.pipe p 2>/dev/null
# -vnc 0.0.0.0:1 -k en-us \
# console=tty0
qemu-system-x86_64 \
    -enable-kvm \
    -m 8192 \
    -smp 2 \
    -cpu host \
    -nographic \
    -vga virtio \
    -boot menu=on \
    -net nic \
    -kernel "${PROJECT_OUTPUT_DIR}/vmlinuz-5.14.0-rc5-linstrap+" \
    -append "console=ttyS0" \
    -initrd "${PROJECT_OUTPUT_DIR}/initrd.img-linstrap${LINSTRAP_VERSION}"
rm /tmp/linstrap.pipe
EOF
        
        chmod a+x "${PROJECT_OUTPUT_DIR}/qemu-start.sh"
    else
        echo "For one or more reasons the project is not in a ready state to be built. Check the previous logs for more information."
    fi
} # | dialog --programbox 40 100
