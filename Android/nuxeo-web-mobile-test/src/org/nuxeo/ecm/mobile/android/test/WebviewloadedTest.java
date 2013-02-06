package org.nuxeo.ecm.mobile.android.test;

public class WebviewloadedTest extends BasisTest {
    public WebviewloadedTest() {
        super();
    }
    
    public void testIntializeWebview() throws Exception {
        waitForNuxeoActivity("org.nuxeo.ecm.mobile.android.NuxeoWebApp");
    }
}
