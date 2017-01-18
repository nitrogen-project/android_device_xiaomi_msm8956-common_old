#!/system/bin/sh

################################################################################
# helper functions to allow Android init like script

function write() {
    echo -n $2 > $1
}

function copy() {
    cat $1 > $2
}

function get-set-forall() {
    for f in $1 ; do
        cat $f
        write $f $2
    done
}

################################################################################

    # HMP scheduler (big.Little cluster related) settings
    write /proc/sys/kernel/sched_boost 0
    write /proc/sys/kernel/sched_upmigrate 95
    write /proc/sys/kernel/sched_downmigrate 85

    write /proc/sys/kernel/sched_window_stats_policy 2
    write /proc/sys/kernel/sched_ravg_hist_size 5

    write /sys/devices/system/cpu/cpu0/sched_mostly_idle_nr_run 3
    write /sys/devices/system/cpu/cpu1/sched_mostly_idle_nr_run 3
    write /sys/devices/system/cpu/cpu2/sched_mostly_idle_nr_run 3
    write /sys/devices/system/cpu/cpu3/sched_mostly_idle_nr_run 3
    write /sys/devices/system/cpu/cpu4/sched_mostly_idle_nr_run 3
    write /sys/devices/system/cpu/cpu5/sched_mostly_idle_nr_run 3

    write /sys/class/devfreq/mincpubw/governor "cpufreq"
    write /sys/class/devfreq/cpubw/governor "bw_hwmon"
    write /sys/class/devfreq/cpubw/bw_hwmon/io_percent 20
    write /sys/class/devfreq/cpubw/bw_hwmon/guard_band_mbps 30
    write /sys/class/devfreq/gpubw/bw_hwmon/io_percent 40

    # Disable thermal
    write /sys/module/msm_thermal/core_control/enabled 0

    # disable thermal bcl hotplug to switch governor
    write /sys/devices/soc.0/qcom,bcl.56/mode "disable"
    write /sys/devices/soc.0/qcom,bcl.56/hotplug_mask 0
    write /sys/devices/soc.0/qcom,bcl.56/hotplug_soc_mask 0
    write /sys/devices/soc.0/qcom,bcl.56/mode "enable"

    # configure governor settings for little cluster
    write /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor impulse
    restorecon -R /sys/devices/system/cpu # must restore after impulse
    write /sys/devices/system/cpu/cpu0/cpufreq/impulse/timer_slack -1
    write /sys/devices/system/cpu/cpu0/cpufreq/impulse/timer_rate 40000
    write /sys/devices/system/cpu/cpu0/cpufreq/impulse/target_loads "80 400000:33 691200:25 806400:50 1017600:65 1190400:70 1305600:85 1382400:90 1401600:92 1440000:98"
    write /sys/devices/system/cpu/cpu0/cpufreq/impulse/min_sample_time 50000
    write /sys/devices/system/cpu/cpu0/cpufreq/impulse/hispeed_freq 1382400
    write /sys/devices/system/cpu/cpu0/cpufreq/impulse/go_hispeed_load 85
    write /sys/devices/system/cpu/cpu0/cpufreq/impulse/above_hispeed_delay 0
    write /sys/devices/system/cpu/cpu0/cpufreq/impulse/align_windows 0
    write /sys/devices/system/cpu/cpu0/cpufreq/impulse/max_freq_hysteresis 166667
    write /sys/devices/system/cpu/cpu0/cpufreq/impulse/powersave_bias 0

    # online CPU4
    write /sys/devices/system/cpu/cpu4/online 1

    # configure governor settings for big cluster
    write /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor ironactive
    restorecon -R /sys/devices/system/cpu # must restore after ironactive
    write /sys/devices/system/cpu/cpu4/cpufreq/ironactive/go_hispeed_load 90
    write /sys/devices/system/cpu/cpu4/cpufreq/ironactive/above_hispeed_delay 0
    write /sys/devices/system/cpu/cpu4/cpufreq/ironactive/timer_rate 20000
    write /sys/devices/system/cpu/cpu4/cpufreq/ironactive/hispeed_freq 1305600
    write /sys/devices/system/cpu/cpu4/cpufreq/ironactive/timer_slack -1
    write /sys/devices/system/cpu/cpu4/cpufreq/ironactive/target_loads "74 998400:73 1056000:64 1113600:80 1190400:61 1248000:69 1305600:64 1382400:74 1612800:69 1747200:67 1804800:72"
    write /sys/devices/system/cpu/cpu4/cpufreq/ironactive/min_sample_time 30000
    write /sys/devices/system/cpu/cpu4/cpufreq/ironactive/boost 0
    write /sys/devices/system/cpu/cpu4/cpufreq/ironactive/align_windows 0
    write /sys/devices/system/cpu/cpu4/cpufreq/ironactive/use_migration_notif 1
    write /sys/devices/system/cpu/cpu4/cpufreq/ironactive/use_sched_load 0
    write /sys/devices/system/cpu/cpu4/cpufreq/ironactive/max_freq_hysteresis 20000
    write /sys/devices/system/cpu/cpu4/cpufreq/ironactive/boostpulse_duration 80000

    # HMP Task packing settings for 8956
    write /proc/sys/kernel/sched_small_task 30
    write /sys/devices/system/cpu/cpu0/sched_mostly_idle_load 20
    write /sys/devices/system/cpu/cpu1/sched_mostly_idle_load 20
    write /sys/devices/system/cpu/cpu2/sched_mostly_idle_load 20
    write /sys/devices/system/cpu/cpu3/sched_mostly_idle_load 20
    write /sys/devices/system/cpu/cpu4/sched_mostly_idle_load 20
    write /sys/devices/system/cpu/cpu5/sched_mostly_idle_load 20

    write /proc/sys/kernel/sched_boost 0

    # Bring up all cores online
    write /sys/devices/system/cpu/cpu1/online 1
    write /sys/devices/system/cpu/cpu2/online 1
    write /sys/devices/system/cpu/cpu3/online 1
    write /sys/devices/system/cpu/cpu4/online 1
    write /sys/devices/system/cpu/cpu5/online 1

    # Enable LPM Prediction
    write /sys/module/lpm_levels/parameters/lpm_prediction 1

    # Enable Low power modes
    write /sys/module/lpm_levels/parameters/sleep_disabled 0

    # Disable L2 GDHS on 8976
    write /sys/module/lpm_levels/system/a53/a53-l2-gdhs/idle_enabled "N"
    write /sys/module/lpm_levels/system/a72/a72-l2-gdhs/idle_enabled "N"

    # Enable sched guided freq control
    write /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_sched_load 1
    write /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_migration_notif 1
    write /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_sched_load 1
    write /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_migration_notif 1
    write /proc/sys/kernel/sched_freq_inc_notify 50000
    write /proc/sys/kernel/sched_freq_dec_notify 50000

    # Configure core_ctl
    write /sys/devices/system/cpu/cpu0/core_ctl/min_cpus 4
    write /sys/devices/system/cpu/cpu0/core_ctl/max_cpus 4
    write /sys/devices/system/cpu/cpu0/core_ctl/busy_up_thres 25
    write /sys/devices/system/cpu/cpu0/core_ctl/busy_down_thres 20
    write /sys/devices/system/cpu/cpu0/core_ctl/offline_delay_ms 1800
    write /sys/devices/system/cpu/cpu0/core_ctl/is_big_cluster 0
#    write /sys/devices/system/cpu/cpu0/core_ctl/not_preferred "1 0 0 0"
    write /sys/devices/system/cpu/cpu4/core_ctl/min_cpus 2
    write /sys/devices/system/cpu/cpu4/core_ctl/max_cpus 2
    write /sys/devices/system/cpu/cpu4/core_ctl/busy_up_thres 68
    write /sys/devices/system/cpu/cpu4/core_ctl/busy_down_thres 40
    write /sys/devices/system/cpu/cpu4/core_ctl/offline_delay_ms 100
    write /sys/devices/system/cpu/cpu4/core_ctl/task_thres 4
    write /sys/devices/system/cpu/cpu4/core_ctl/is_big_cluster 1
#    write /sys/devices/system/cpu/cpu4/core_ctl/not_preferred "1 0"

    # msm_perfomance
    write /sys/module/msm_performance/parameters/touchboost 0

    # Re-enable thermal
    write /sys/module/msm_thermal/core_control/enabled 1

    # Re-enable BCL hotplug
    write /sys/devices/soc.0/qcom,bcl.56/mode "disable"
    write /sys/devices/soc.0/qcom,bcl.56/hotplug_mask 48
    write /sys/devices/soc.0/qcom,bcl.56/hotplug_soc_mask 32
    write /sys/devices/soc.0/qcom,bcl.56/mode "enable"

    # Enable timer migration to little cluster
    write /proc/sys/kernel/power_aware_timer_migration 1

    # Enable sched colocation and colocation inheritance
    write /proc/sys/kernel/sched_grp_upmigrate 130
    write /proc/sys/kernel/sched_grp_downmigrate 110
    write /proc/sys/kernel/sched_enable_thread_grouping 1

    # set (super) packing parameters
    write /sys/devices/system/cpu/cpu0/sched_mostly_idle_freq 1017600
    write /sys/devices/system/cpu/cpu4/sched_mostly_idle_freq 0

    # Enable adaptive LMK
    write /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk 1
    write /sys/module/lowmemorykiller/parameters/vmpressure_file_min 81250

    chmod 0660 /sys/module/lowmemorykiller/parameters/minfree
    write /sys/module/lowmemorykiller/parameters/minfree "14746,18432,22118,25805,40000,55000"

    # Vibrator intensity (max - 3596, min - 116)
    write /sys/class/timed_output/vibrator/vtg_level 1800