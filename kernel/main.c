//
//  inspector.c
//  inspector
//
//  Created by Valentin Shilnenkov on 21/6/24.
//

#include <mach/mach_types.h>
#include <libkern/libkern.h>
#include "mod.h"

kern_return_t inspector_start(kmod_info_t * ki, void *d);
kern_return_t inspector_stop(kmod_info_t *ki, void *d);

kern_return_t inspector_start(kmod_info_t * ki, void *d)
{
    printf("inspector is loaded!\n");
    return KERN_SUCCESS;
}

kern_return_t inspector_stop(kmod_info_t *ki, void *d)
{
    printf("inspector is unloaded!\n");
    return KERN_SUCCESS;
}
