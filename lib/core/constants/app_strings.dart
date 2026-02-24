/// Centralized String Constants
/// All hardcoded strings used across the application should be defined here
class AppStrings {
  // ========== APP INFO ==========
  static const String appName = 'Wood Service';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Quality Wood Services';

  // ========== AUTHENTICATION ==========
  static const String welcome = 'Welcome to Wood Service';
  static const String login = 'Login';
  static const String register = 'Register';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String name = 'Name';
  static const String firstName = 'First Name';
  static const String lastName = 'Last Name';
  static const String phone = 'Phone';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';
  static const String dontHaveAccount = 'Don\'t have an account?';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String createAccount = 'Create Account';
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';

  // ========== NAVIGATION ==========
  static const String home = 'Home';
  static const String products = 'Products';
  static const String services = 'Services';
  static const String orders = 'Orders';
  static const String cart = 'Cart';
  static const String favorites = 'Favorites';
  static const String profile = 'Profile';
  static const String settings = 'Settings';
  static const String notifications = 'Notifications';
  static const String messages = 'Messages';
  static const String search = 'Search';

  // ========== ORDERS ==========
  static const String myOrders = 'My Orders';
  static const String orderDetails = 'Order Details';
  static const String orderHistory = 'Order History';
  static const String pendingOrders = 'Pending Orders';
  static const String acceptedOrders = 'Accepted Orders';
  static const String completedOrders = 'Completed Orders';
  static const String cancelledOrders = 'Cancelled Orders';
  static const String placeOrder = 'Place Order';
  static const String cancelOrder = 'Cancel Order';
  static const String trackOrder = 'Track Order';
  static const String orderStatus = 'Order Status';
  static const String orderDate = 'Order Date';
  static const String orderTotal = 'Order Total';
  static const String orderId = 'Order ID';

  // ========== PRODUCTS/SERVICES ==========
  static const String productDetails = 'Product Details';
  static const String serviceDetails = 'Service Details';
  static const String addToCart = 'Add to Cart';
  static const String buyNow = 'Buy Now';
  static const String addToFavorites = 'Add to Favorites';
  static const String removeFromFavorites = 'Remove from Favorites';
  static const String quantity = 'Quantity';
  static const String price = 'Price';
  static const String total = 'Total';
  static const String description = 'Description';
  static const String specifications = 'Specifications';
  static const String reviews = 'Reviews';
  static const String rating = 'Rating';
  static const String customerReviews = 'Customer Reviews';
  static const String noReviews = 'No reviews yet';
  static const String beFirstToReview = 'Be the first to review this product';

  // ========== CART ==========
  static const String shoppingCart = 'Shopping Cart';
  static const String cartEmpty = 'Your cart is empty';
  static const String continueShopping = 'Continue Shopping';
  static const String checkout = 'Checkout';
  static const String subtotal = 'Subtotal';
  static const String tax = 'Tax';
  static const String shipping = 'Shipping';
  static const String grandTotal = 'Grand Total';
  static const String removeItem = 'Remove Item';

  // ========== SELLER ==========
  static const String sellerDashboard = 'Seller Dashboard';
  static const String myProducts = 'My Products';
  static const String addProduct = 'Add Product';
  static const String editProduct = 'Edit Product';
  static const String deleteProduct = 'Delete Product';
  static const String uploadProduct = 'Upload Product';
  static const String productManagement = 'Product Management';
  static const String orderManagement = 'Order Management';
  static const String acceptOrder = 'Accept Order';
  static const String rejectOrder = 'Reject Order';
  static const String startOrder = 'Start Order';
  static const String completeOrder = 'Complete Order';
  static const String addNote = 'Add Note';
  static const String orderNotes = 'Order Notes';

  // ========== PROFILE ==========
  static const String myProfile = 'My Profile';
  static const String editProfile = 'Edit Profile';
  static const String saveChanges = 'Save Changes';
  static const String changePassword = 'Change Password';
  static const String appPreferences = 'App Preferences';
  static const String language = 'Language';
  static const String darkMode = 'Dark Mode';
  static const String notificationsSettings = 'Notifications';

  // ========== MESSAGES ==========
  static const String noMessages = 'No messages yet';
  static const String typeMessage = 'Type a message...';
  static const String send = 'Send';
  static const String online = 'Online';
  static const String offline = 'Offline';
  static const String lastSeen = 'Last seen';

  // ========== ERRORS ==========
  static const String error = 'Error';
  static const String somethingWentWrong = 'Something went wrong';
  static const String networkError = 'Network Error';
  static const String noInternetConnection = 'No Internet Connection';
  static const String serverError = 'Server Error';
  static const String unauthorized = 'Unauthorized';
  static const String notFound = 'Not Found';
  static const String badRequest = 'Bad Request';
  static const String tryAgain = 'Try Again';
  static const String retry = 'Retry';

  // ========== SUCCESS ==========
  static const String success = 'Success';
  static const String operationSuccessful = 'Operation completed successfully';
  static const String saved = 'Saved';
  static const String updated = 'Updated';
  static const String deleted = 'Deleted';
  static const String added = 'Added';
  static const String removed = 'Removed';

  // ========== VALIDATION ==========
  static const String requiredField = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String invalidInput = 'Invalid input';

  // ========== LOADING ==========
  static const String loading = 'Loading...';
  static const String pleaseWait = 'Please wait...';
  static const String processing = 'Processing...';

  // ========== EMPTY STATES ==========
  static const String noData = 'No data available';
  static const String noProducts = 'No products found';
  static const String noOrders = 'No orders found';
  static const String noFavorites = 'No favorites yet';
  static const String noNotifications = 'No notifications';

  // ========== ACTIONS ==========
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String update = 'Update';
  static const String add = 'Add';
  static const String remove = 'Remove';
  static const String confirm = 'Confirm';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String ok = 'OK';
  static const String close = 'Close';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String previous = 'Previous';
  static const String finish = 'Finish';
  static const String skip = 'Skip';
  static const String done = 'Done';
  static const String view = 'View';
  static const String viewAll = 'View All';
  static const String seeMore = 'See More';
  static const String seeLess = 'See Less';

  // ========== DATE/TIME ==========
  static const String today = 'Today';
  static const String yesterday = 'Yesterday';
  static const String tomorrow = 'Tomorrow';
  static const String ago = 'ago';
  static const String justNow = 'Just now';
  static const String minutesAgo = 'minutes ago';
  static const String hoursAgo = 'hours ago';
  static const String daysAgo = 'days ago';
  static const String weeksAgo = 'weeks ago';
  static const String monthsAgo = 'months ago';
  static const String yearsAgo = 'years ago';
}
