program perlin_test
    use iso_fortran_env
    implicit none

    integer, parameter :: IMAGE_DIM = 1024
    integer, parameter :: NUM_ITERATIONS = 100
    character, parameter, dimension(6) :: symbols = (/ "   ", "░", "▒", "▓", "█", "█" /)
    real(kind=4), allocatable, dimension(:,:) :: pixels
    real(kind=4), dimension(IMAGE_DIM,2) :: rgradients
    integer, dimension(IMAGE_DIM) :: permutations = 0
    integer :: symbol_index, i, x, y, seed
    real(kind=4) :: temp, perlin_noise

    ! Initialize the RNG
    seed = 0
    call random_seed(seed)

    allocate(pixels(IMAGE_DIM, IMAGE_DIM))

    ! Initialize the vectors used to generate the noise
    call init_gradients(rgradients, IMAGE_DIM)
    call init_permutations(permutations, IMAGE_DIM)

    do i = 1,NUM_ITERATIONS
        do x = 1,IMAGE_DIM
            do y = 1,IMAGE_DIM
                temp = perlin_noise(rgradients, permutations, x * 0.1, y * 0.1, IMAGE_DIM)
                pixels(y,x) = temp * 0.5 + 0.5
            end do
        end do
    end do

    do x = 1,IMAGE_DIM
        do y = 1,IMAGE_DIM
            symbol_index = nint(pixels(y,x) * 5.)
            write (*,*) symbols(symbol_index)
        end do
        write (*,*) "\n"
    end do
end program

subroutine init_gradients(rgradients, image_dim)
    integer, intent(in) :: image_dim
    real(kind=4), intent(out), dimension(image_dim,2) :: rgradients

    real(kind=4) :: rand_value
    real(kind=4) :: pi
    integer i

    pi = 4. * atan(1.)
    do i = 1, image_dim
        call random_number(rand_value)
        rand_value = rand_value / (2. * pi)
        rgradients(i,1) = cos(rand_value)
        rgradients(i,2) = sin(rand_value)
    end do
end subroutine init_gradients

subroutine init_permutations(permutations, image_dim)
    integer, intent(in) :: image_dim
    integer, intent(inout), dimension(image_dim) :: permutations

    real(kind=4) :: rand_value
    integer :: rand_int, i

    do i = 1, image_dim
        call random_number(rand_value)
        rand_int = nint(rand_value * (i + 1))
        permutations(i) = permutations(j)
        permutations(j) = i
    end do
end subroutine init_permutations

function perlin_noise(rgradients, permutations, x, y, image_dim)
    real(kind=4) :: perlin_noise ! Return value
    integer, intent(in) :: image_dim
    real(kind=4), intent(in) :: x, y
    real(kind=4), intent(in), dimension(image_dim,2) :: rgradients
    integer, intent(in), dimension(image_dim) :: permutations
    real(kind=4), dimension(2) :: grad0, grad1, grad2, grad3, origin0, origin1, origin2, origin3, p

    integer :: x0, x1, y0, y1
    real(kind=4) :: v0, v1, v2, v3, fx, fy, vx0, vx1
    real(kind=4) :: smooth, linterp

    x0 = int(x)
    y0 = int(y)
    x1 = x0 + 1
    y1 = y0 + 1

    p = (/ x, y /)
    origin0 = (/ real(x0), real(y0) /)
    origin1 = (/ real(x0) + 1., real(y0) /)
    origin2 = (/ real(x0), real(y0) + 1. /)
    origin3 = (/ real(x0) + 1., real(y0) + 1. /)

    grad0 = rgradients(mod(permutations(x0) + permutations(y0), image_dim), :)
    grad1 = rgradients(mod(permutations(x1) + permutations(y0), image_dim), :)
    grad2 = rgradients(mod(permutations(x0) + permutations(y1), image_dim), :)
    grad3 = rgradients(mod(permutations(x1) + permutations(y1), image_dim), :)

    v0 = gradient(origin0, grad0, p)
    v1 = gradient(origin1, grad1, p)
    v2 = gradient(origin2, grad2, p)
    v3 = gradient(origin3, grad3, p)

    fx = smooth(x - origin0(1))
    fy = smooth(y - origin0(2))
    vx0 = linterp(v0, v1, fx)
    vx1 = linterp(v2, v3, fx)

    perlin_noise = linterp(vx0, vx1, fy)
end function perlin_noise

function gradient(orig, grad, p)
    real(kind=4), intent(in), dimension(2) :: orig, grad, p
    real(kind=4) :: gradient ! Return value
    gradient = grad(1) * (p(1) - orig(1)) + grad(2) * (p(2) - orig(2))
end function gradient

function smooth(v)
    real(kind=4), intent(in) :: v
    real(kind=4) :: smooth
    smooth = v * v * (3. - 2. * v)
end function smooth

function linterp(a, b, v)
    real(kind=4), intent(in) :: a, b, v
    real(kind=4) :: linterp
    linterp = a * (1. - v) + b * v
end function linterp

