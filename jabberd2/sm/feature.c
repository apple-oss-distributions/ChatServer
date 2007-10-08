/*
 * jabberd - Jabber Open Source Server
 * Copyright (c) 2002 Jeremie Miller, Thomas Muldowney,
 *                    Ryan Eatmon, Robert Norris
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA02111-1307USA
 */

#include "sm.h"

/** @file sm/feature.c
  * @brief feature registration
  * @author Robert Norris
  * $Date: 2006/03/14 23:27:27 $
  * $Revision: 1.1 $
  */

/*
 * these are simple wrappers around xhash for the moment. perhaps a little
 * redundant, but they will give a good abstraction, and make it easier to
 * add stuff in the future .. f-neg comes to mind.
 */

/** register a feature */
void feature_register(sm_t sm, char *feature)
{
    log_debug(ZONE, "registering feature %s", feature);

    xhash_put(sm->features, pstrdup(xhash_pool(sm->features), feature), (void *) 1);
}

/** unregister feature */
void feature_unregister(sm_t sm, char *feature)
{
    log_debug(ZONE, "unregistering feature %s", feature);

    xhash_zap(sm->features, feature);
}