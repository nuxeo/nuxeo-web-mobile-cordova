/*
 * (C) Copyright 2011 Nuxeo SAS (http://nuxeo.com/) and contributors.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the GNU Lesser General Public License
 * (LGPL) version 2.1 which accompanies this distribution, and is available at
 * http://www.gnu.org/licenses/lgpl.html
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * Contributors:
 *     Nuxeo - initial API and implementation
 */

package org.nuxeo.ecm.mobile.android.test;

import java.lang.reflect.Method;
import java.util.ArrayList;

import org.nuxeo.ecm.mobile.android.NuxeoWebApp;

import android.app.Activity;
import android.content.Context;
import android.test.ActivityInstrumentationTestCase2;
import android.test.suitebuilder.annotation.SmallTest;
import android.view.View;
import android.view.inputmethod.InputMethodManager;

import com.jayway.android.robotium.solo.Solo;

/**
 * Test annotations:
 * Small: No interaction with any file system or network.
 * Medium: Access to file systems on box which is running tests.
 * Large: Access to external file systems, networks, etc.
 *
 */
public abstract class BasisTest extends
        ActivityInstrumentationTestCase2<NuxeoWebApp> {

    protected static final int ACTIVITY_WAIT_MILLIS = 2000;

    protected static final int NUMBER_OF_TRIES = 20;

    protected Solo solo;

    public BasisTest() {
        super("org.nuxeo.ecm.mobile.android", NuxeoWebApp.class);
    }

    @Override
    public void setUp() throws Exception {
        solo = new Solo(getInstrumentation(), getActivity());
    }

    @Override
    public void tearDown() throws Exception {
        try {
            solo.finalize();
        } catch (Throwable e) {
            e.printStackTrace();
        }
        getActivity().finish();
        super.tearDown();
    }

    /**
     * Enhanced view finder. First tries to find it from Activity, then from all
     * Views under ViewRoot.
     */
    protected final View findViewById(int id) {
        View view = solo.getView(id);
        if (view != null)
            return view;

        ArrayList<View> views = solo.getViews();
        for (View v : views) {
            if (v.getId() == id) {
                return v;
            }
        }
        return null;
    }

    protected boolean waitForActivity(String activityName, long timeout) {
        long now = System.currentTimeMillis();
        long endTime;
        for (endTime = now + timeout; !solo.getCurrentActivity().getClass().getName().equals(
                activityName)
                && now < endTime; now = System.currentTimeMillis())
            ;
        return now < endTime;
    }

    protected boolean waitForNuxeoActivity(String activityName)
            throws Exception {
        Thread.sleep(300);
        boolean result = waitForActivity(activityName, ACTIVITY_WAIT_MILLIS);

        if (!result) {
            String currentActivityName = solo.getCurrentActivity().getClass().getName();
            throw new AssertionError("Unable to find activity " + activityName
                    + " ( current name is " + currentActivityName + ")");
        }

        Activity currentActivity = solo.getCurrentActivity();

        Method method = null;

        try {
            method = currentActivity.getClass().getMethod("isReady");
        } catch (NoSuchMethodException e) {

        }

        if (method == null) {
            if (!currentActivity.getClass().getSimpleName().equals(
                    "NuxeoWebApp")) {
                throw new RuntimeException("Unable to find isReady method");
            }
            return result;
        }

        boolean ready = (Boolean) method.invoke(currentActivity);
        int nbTry = NUMBER_OF_TRIES;
        while (!ready && nbTry > 0) {
            Thread.sleep(300);
            ready = (Boolean) method.invoke(currentActivity);
            nbTry -= 1;
        }
        return ready;
    }

    protected View findViewByTag(String tag) {
        return solo.getCurrentActivity().getWindow().getDecorView().findViewWithTag(
                tag);
    }

    /**
     * Sometimes, we need to hide the soft keyboard, because the virtual
     * keyboard process seems to intercept the touch event.
     *
     * <p>
     * See
     * http://code.google.com/p/robotium/issues/detail?can=1&q=133&colspec=ID
     * %20Type%20Stars%20Status%20Priority%20Milestone%20Owner%20Summary&id=133
     * for the discussion thread.
     * </p>
     *
     * @param editText
     */
    protected void hideSoftKeyboard(final View editText) {
        final InputMethodManager inputMethodManager = (InputMethodManager) solo.getCurrentActivity().getSystemService(
                Context.INPUT_METHOD_SERVICE);
        inputMethodManager.hideSoftInputFromWindow(editText.getWindowToken(), 0);
    }

    /**
     * The name 'test preconditions' is a convention to signal that if this
     * test doesn't pass, the test case was not set up properly and it might
     * explain any and all failures in other tests. This is not guaranteed
     * to run before other tests, as JUnit uses reflection to find the tests.
     */
    @SmallTest
    public void testPreconditions() {
    }

}
