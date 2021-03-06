
module quadrature2

    use omp_lib

contains

real(kind=8) function trapezoid(f, a, b, n)

    ! Estimate the integral of f(x) from a to b using the
    ! Trapezoid Rule with n points.

    ! Input:
    !   f:  the function to integrate
    !   a:  left endpoint
    !   b:  right endpoint
    !   n:  number of points to use
    ! Returns:
    !   the estimate of the integral
     
    implicit none
    real(kind=8), intent(in) :: a,b
    real(kind=8), external :: f
    integer, intent(in) :: n

    ! Local variables:
    integer :: j
    real(kind=8) :: h, trap_sum, xj

    h = (b-a)/(n-1)
    trap_sum = 0.5d0*(f(a) + f(b))  ! endpoint contributions
    
    !$omp parallel do private(xj) reduction(+ : trap_sum) 
    do j=2,n-1
        xj = a + (j-1)*h
        trap_sum = trap_sum + f(xj)
        enddo

    trapezoid = h * trap_sum

end function trapezoid


real(kind=8) function simpson(f, a, b, n)

    ! Estimate the integral of f(x) from a to b using the
    ! Simpson Rule with n points.

    ! Input:
    !   f:  the function to integrate
    !   a:  left endpoint
    !   b:  right endpoint
    !   n:  number of points to use
    ! Returns:
    !   the estimate of the integral
     
    implicit none
    real(kind=8), intent(in) :: a,b
    real(kind=8), external :: f
    integer, intent(in) :: n
!    real, dimension(:), allocatable :: xj, xc, fj, fc
    ! Local variables:
!    integer :: i,j 
!    real(kind=8) :: h
!    real(kind=8) :: sumfj, sumfc


!print *, 'before allocate'
!    allocate(xj(n))
!    allocate(fj(n))
!    allocate(xc(n-1))
!    allocate(fc(n-1))
!print *, 'after  allocate'
!    h = (b-a)/(n-1)
!    do i= 1, n
!        xj(i) = a + (i*h)
!    enddo
!print *, 'after  first do loop'

!    fj = f(xj)   
!print *, 'after fj asgn'
!    do i=1, n-1
!        xc(i) = a+h/2.d0 + (i*h)
!    enddo
!print *, 'after second do loop'
!    fc = f(xc)
!print *, 'after fc asgn'    
!    !$omp parallel do private(xj) reduction(+ : trap_sum) 

!     sumfj = sum(fj)
!     sumfc = sum(fc)
!print *, 'after sum'
!    simpson = (h/6.d0) * (2.d0*sumfj - (fj(1) + fj(n)) + 4.d0*sumfc))



    ! Local variables:
    integer :: j
    real(kind=8) :: h, simpson_sum, xj, xc

    h = (b-a)/(n-1)
    simpson_sum = f(a) + f(b)  ! endpoint contributions
    
    !$omp parallel do private(xj) reduction(+ : simpson_sum) 
    do j=2,n-1
        xj = a + (j-1)*h
        simpson_sum = simpson_sum + 2.d0*f(xj)
        enddo

    !$omp parallel do private(xc) reduction(+ : simpson_sum) 
    do j=1,n-1
        xc = a + (j-0.5d0)*h
        simpson_sum = simpson_sum + 4.d0*f(xc)
        enddo

    simpson = (h/6.d0) * simpson_sum


end function simpson


real(kind=8) function simpson2(f, a, b, n)

    ! Estimate the integral of f(x) from a to b using the
    ! Simpson Rule with n points.

    ! Input:
    !   f:  the function to integrate
    !   a:  left endpoint
    !   b:  right endpoint
    !   n:  number of points to use
    ! Returns:
    !   the estimate of the integral
     
    implicit none
    real(kind=8), intent(in) :: a,b
    real(kind=8), external :: f
    integer, intent(in) :: n
    real, dimension(:), allocatable :: xj, xc, fj, fc
    ! Local variables:
    integer :: i,j 
    real(kind=8) :: h
    real(kind=8) :: sumfj, sumfc


!print *, 'before allocate'
    allocate(xj(n))
    allocate(fj(n))
    allocate(xc(n-1))
    allocate(fc(n-1))
!print *, 'after  allocate'
    h = (b-a)/(n-1)
    do i= 1, n
        xj(i) = a + (i*h)
    enddo
!print *, 'after  first do loop'

    fj = f(xj)   
!print *, 'after fj asgn'
    do i=1, n-1
        xc(i) = a+h/2.d0 + (i*h)
    enddo
!print *, 'after second do loop'
    fc = f(xc)
!print *, 'after fc asgn'    
!    !$omp parallel do private(xj) reduction(+ : trap_sum) 

     sumfj = sum(fj)
     sumfc = sum(fc)
!print *, 'after sum'
    simpson2 = (h/6.d0) * (2.d0*sumfj - (fj(1) + fj(n)) + 4.d0*sumfc)

end function simpson2




subroutine error_table(f,a,b,nvals,int_true,method)

    ! Compute and print out a table of errors when the quadrature
    ! rule specified by the input function method is applied for
    ! each value of n in the array nvals.

    implicit none
    real(kind=8), intent(in) :: a,b, int_true
    real(kind=8), external :: f, method
    integer, dimension(:), intent(in) :: nvals

    ! Local variables:
    integer :: j, n
    real(kind=8) :: ratio, last_error, error, int_approx

    print *, "      n         approximation        error       ratio"
    last_error = 0.d0   
    do j=1,size(nvals)
        n = nvals(j)
!print *, 'before simpson call'
        int_approx = method(f,a,b,n)
!print *, 'after simpson call'
        error = abs(int_approx - int_true)
        ratio = last_error / error
        last_error = error  ! for next n

        print 11, n, int_approx, error, ratio
 11     format(i8, es22.14, es13.3, es13.3)
        enddo

end subroutine error_table


end module quadrature2

