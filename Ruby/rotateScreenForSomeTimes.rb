#!/usr/bin/env ruby

#禁用自动旋转：
`adb shell content insert --uri content://settings/system --bind name:s:accelerometer_rotation --bind value:i:0`

rotateCounter=0
targetRotateTimes=66 #46 #66 #86
sleepDuration=0.125


sleep sleepDuration


while true do

    #横屏：
        `adb shell content insert --uri content://settings/system --bind name:s:user_rotation --bind value:i:1`

        sleep sleepDuration

        #竖屏：
            `adb shell content insert --uri content://settings/system --bind name:s:user_rotation --bind value:i:0`

            sleep sleepDuration

                #反向竖屏：
            `adb shell content insert --uri content://settings/system --bind name:s:user_rotation --bind value:i:2`

            sleep sleepDuration

            #反向横屏:
            `adb shell content insert --uri content://settings/system --bind name:s:user_rotation --bind value:i:3`
            
    sleep sleepDuration

    rotateCounter+=1

    if rotateCounter > targetRotateTimes
        break
    end
end
